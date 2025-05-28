import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservationsPage extends StatefulWidget {
  final String userId;

  const ReservationsPage({super.key, required this.userId});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateReservationStatus(); // Call to update reservation statuses
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to update Reservations status to 'Terminée' for past trips
  Future<void> _updateReservationStatus() async {
    try {
      final now = Timestamp.now();
      final reservationsCollection = FirebaseFirestore.instance.collection('Reservations');

      // Find reservations with status not 'Annulée' or 'Terminée'
      final reservationsSnapshot = await reservationsCollection
          .where('clientId', isEqualTo: widget.userId)
          .where('status', whereNotIn: ['Annulée', 'Terminée'])
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (var reservationDoc in reservationsSnapshot.docs) {
        final reservationData = reservationDoc.data();
        final trajetId = reservationData['trajetId'] as String?;

        if (trajetId != null) {
          final trajetDoc = await FirebaseFirestore.instance.collection('Trajets').doc(trajetId).get();
          if (trajetDoc.exists) {
            final dateDepart = trajetDoc.data()?['dateDepart'] as Timestamp?;
            if (dateDepart != null && dateDepart.toDate().isBefore(DateTime.now())) {
              final reservationRef = reservationsCollection.doc(reservationDoc.id);
              batch.update(reservationRef, {
                'status': 'Terminée',
                'updatedAt': Timestamp.now(),
              });
            }
          }
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des statuts: $e');
    }
  }

  // Function to handle reservation cancellation with transaction
  Future<void> _cancelReservation(BuildContext context, String reservationId, Map<String, dynamic> reservation) async {
    try {
      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmer l\'annulation', style: GoogleFonts.poppins()),
          content: Text('Voulez-vous vraiment annuler cette réservation ?', style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Non', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Oui', style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      final trajetId = reservation['trajetId'] ?? 'N/A';
      final seats = reservation['seats'] ?? 0;
      final driverCommission = reservation['price'] != null ? (reservation['price'] * 0.1).round() : 0;
      final status = reservation['status'] ?? 'N/A';

      // Check if reservation is cancellable
      if (status.toLowerCase() == 'annulée') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cette réservation est déjà annulée', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Fetch trajet data for date check
      final trajetDoc = await FirebaseFirestore.instance.collection('Trajets').doc(trajetId).get();
      if (!trajetDoc.exists) {
        throw Exception("Trajet non trouvé");
      }
      final dateDepart = (trajetDoc.data()?['dateDepart'] as Timestamp?)?.toDate();

      // Check if cancellation is within 24 hours
      if (dateDepart != null && dateDepart.isBefore(DateTime.now().add(const Duration(hours: 24)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'annuler moins de 24 heures avant le trajet', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Fetch user data for notification
      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        throw Exception("Utilisateur non trouvé");
      }
      final userData = userDoc.data() as Map<String, dynamic>;

      // Run Firestore transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // References
        final reservationRef = FirebaseFirestore.instance.collection('Reservations').doc(reservationId);
        final trajetRef = FirebaseFirestore.instance.collection('Trajets').doc(trajetId);
        final driverRef = FirebaseFirestore.instance.collection('Chauffeur').doc(reservation['chauffeurId']);
        final notificationRef = FirebaseFirestore.instance.collection('Notifications').doc();

        // Get documents
        final reservationDoc = await transaction.get(reservationRef);
        final trajetDoc = await transaction.get(trajetRef);
        final driverDoc = await transaction.get(driverRef);

        // Validate documents existence
        if (!reservationDoc.exists) {
          throw Exception("Réservation non trouvée");
        }
        if (!trajetDoc.exists) {
          throw Exception("Trajet non trouvé");
        }
        if (!driverDoc.exists) {
          throw Exception("Chauffeur non trouvé");
        }

        // Update reservation status
        transaction.update(reservationRef, {
          'status': 'Annulée',
          'updatedAt': Timestamp.now(),
        });

        // Update trajet seats
        transaction.update(trajetRef, {
          'placesDisponibles': FieldValue.increment(seats),
          'placesReservees': FieldValue.increment(-seats),
        });

        // Update driver data if no active subscription
        if (driverDoc.data()?['abonnementActif'] != true) {
          transaction.update(driverRef, {
            'solde': FieldValue.increment(driverCommission),
            'historiqueTransactions': FieldValue.arrayUnion([
              {
                'type': 'remboursement',
                'description': 'Remboursement pour la réservation annulée: ${trajetDoc.data()?['depart'] ?? 'N/A'} → ${trajetDoc.data()?['destination'] ?? 'N/A'}',
                'montant': driverCommission,
                'date': Timestamp.now(),
                'reservationId': reservationId,
              }
            ]),
          });
        }

        // Create notification for driver
        transaction.set(
          notificationRef,
          {
            'chauffeurId': reservation['chauffeurId'] ?? '',
            'message':
                'Annulation de réservation pour votre trajet ${trajetDoc.data()?['depart'] ?? 'N/A'} → ${trajetDoc.data()?['destination'] ?? 'N/A'} '
                'par ${userData['nom'] ?? 'N/A'} ${userData['prenom'] ?? ''} '
                '(${seats} place${seats > 1 ? 's' : ''}). '
                'Remboursement: $driverCommission DZD.',
            'timestamp': Timestamp.now(),
            'read': false,
            'type': 'cancellation',
            'reservationId': reservationId,
          },
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation annulée avec succès', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'annulation: $e');
      String errorMessage = e.toString().contains('permission-denied')
          ? 'Vous n\'avez pas la permission d\'annuler cette réservation. Vérifiez votre connexion ou contactez le support.'
          : 'Erreur: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Get status color based on reservation status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terminée':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mes Réservations',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF09183F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          indicatorColor: Colors.white,
          labelColor: Colors.amber,
          unselectedLabelColor: const Color.fromARGB(255, 214, 214, 214),
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Annulée'),
            Tab(text: 'Terminée'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reservations')
            .where('clientId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF09183F)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune réservation trouvée',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final reservations = snapshot.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _categorizeReservations(reservations),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF09183F)));
              }
              if (futureSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur: ${futureSnapshot.error}',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                  ),
                );
              }

              final pendingReservations = futureSnapshot.data![0]['reservations'] as List<QueryDocumentSnapshot>;
              final cancelledReservations = futureSnapshot.data![1]['reservations'] as List<QueryDocumentSnapshot>;
              final completedReservations = futureSnapshot.data![2]['reservations'] as List<QueryDocumentSnapshot>;

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildReservationList(context, pendingReservations),
                  _buildReservationList(context, cancelledReservations),
                  _buildReservationList(context, completedReservations),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Function to categorize reservations based on status and Trajets.dateDepart
  Future<List<Map<String, dynamic>>> _categorizeReservations(List<QueryDocumentSnapshot> reservations) async {
    final pendingReservations = <QueryDocumentSnapshot>[];
    final cancelledReservations = <QueryDocumentSnapshot>[];
    final completedReservations = <QueryDocumentSnapshot>[];

    final now = DateTime.now();

    for (var doc in reservations) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? 'N/A').toLowerCase();
      final trajetId = data['trajetId'] as String?;

      if (status == 'annulée') {
        cancelledReservations.add(doc);
      } else if (status == 'en attente') {
        pendingReservations.add(doc);
      } else {
        // Check Trajets.dateDepart for completed status
        if (trajetId != null) {
          final trajetDoc = await FirebaseFirestore.instance.collection('Trajets').doc(trajetId).get();
          if (trajetDoc.exists) {
            final dateDepart = trajetDoc.data()?['dateDepart'] as Timestamp?;
            if (dateDepart != null && dateDepart.toDate().isBefore(now)) {
              // Si le trajet est expiré mais pas encore marqué comme terminé, on met à jour
              
                await FirebaseFirestore.instance.collection('Trajets').doc(trajetId).update({'statut': 'terminée'});
              
              completedReservations.add(doc);

            } else if (status == 'terminée') {
              completedReservations.add(doc);
              
            } else {
              pendingReservations.add(doc); // Fallback for non-past reservations
            }
          } else {
            pendingReservations.add(doc); // Fallback if trajet not found
          }
        } else {
          pendingReservations.add(doc); // Fallback if no trajetId
        }
      }
    }

    return [
      {'category': 'pending', 'reservations': pendingReservations},
      {'category': 'cancelled', 'reservations': cancelledReservations},
      {'category': 'completed', 'reservations': completedReservations},
    ];
  }

  Widget _buildReservationList(BuildContext context, List<QueryDocumentSnapshot> reservations) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(
          'Aucune réservation dans cette catégorie',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index].data() as Map<String, dynamic>;
        final reservationId = reservations[index].id;
        final date = (reservation['date'] as Timestamp?)?.toDate();
        final trajetId = reservation['trajetId'] ?? 'N/A';
        final chauffeurId = reservation['chauffeurId'] ?? 'N/A';
        final status = reservation['status'] ?? 'N/A';

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Trajets').doc(trajetId).get(),
          builder: (context, trajetSnapshot) {
            if (trajetSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            if (trajetSnapshot.hasError) {
              return _buildErrorCard('Erreur lors du chargement du trajet');
            }

            final trajetData = trajetSnapshot.data?.data() as Map<String, dynamic>? ?? {};

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Chauffeur').doc(chauffeurId).get(),
              builder: (context, driverSnapshot) {
                if (driverSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (driverSnapshot.hasError) {
                  return _buildErrorCard('Erreur lors du chargement des informations du chauffeur');
                }

                final driverData = driverSnapshot.data?.data() as Map<String, dynamic>? ?? {};

                return Card(
                  color: Color.fromARGB(255, 237, 243, 250),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${trajetData['depart'] ?? 'N/A'} → ${trajetData['destination'] ?? 'N/A'}",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF09183F),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.person,
                          "Chauffeur: ${driverData['nom'] ?? 'N/A'} ${driverData['prenom'] ?? ''}",
                        ),
                        _buildInfoRow(
                          Icons.phone,
                          "Téléphone: ${driverData['phone'] ?? 'N/A'}",
                        ),
                        _buildInfoRow(
                          Icons.calendar_today,
                          "Date de Depart: ${trajetData['dateDepart'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(trajetData['dateDepart'].toDate()) : 'Non spécifiée'}",
                        ),
                        _buildInfoRow(
                          Icons.event_seat,
                          "Places réservées: ${reservation['seats']?.toString() ?? '0'}",
                        ),
                        _buildInfoRow(
                          Icons.monetization_on,
                          "Prix total: ${reservation['price']?.toString() ?? '0'} DZD",
                        ),
                        const SizedBox(height: 12),
                        if (status.toLowerCase() == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(left: 170),
                            child: Container(
                              width: 130,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Align(
                                child: TextButton.icon(
                                  onPressed: () => _cancelReservation(context, reservationId, reservation),
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  label: Text(
                                    'Annuler',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}