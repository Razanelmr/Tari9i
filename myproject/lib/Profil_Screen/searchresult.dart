import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Profil_Screen/ReservationsPage.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsPage extends StatelessWidget {
  final String userId;
  final List<Map<String, dynamic>> searchResults;
  final int seats;

  const ResultsPage({
    super.key,
    required this.userId,
    required this.searchResults,
    required this.seats,
  });

  Future<void> reserveRide(
    BuildContext context,
    String trajetId,
    Map<String, dynamic> trajetData,
    Map<String, dynamic> driverData,
  ) async {
    try {
      // Validate inputs
      if (seats <= 0) {
        throw Exception("Le nombre de places doit être supérieur à 0");
      }
      final prixParPassager = trajetData['prixParPassager'] as num? ?? 0;
      if (prixParPassager < 0) {
        throw Exception("Le prix par passager est invalide");
      }

      // Fetch user data
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("Utilisateur non trouvé");
      }
      final userData = userDoc.data() as Map<String, dynamic>;

      final reservationRef = FirebaseFirestore.instance.collection('Reservations').doc();
      final reservationId = reservationRef.id;

      final totalPrice = prixParPassager * seats;
      final driverCommission = totalPrice * 0.1;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Read Trajet
        final trajetRef = FirebaseFirestore.instance.collection('Trajets').doc(trajetId);
        final trajetDoc = await transaction.get(trajetRef);
        if (!trajetDoc.exists) {
          throw Exception("Trajet non trouvé");
        }
        final availableSeats = trajetDoc['placesDisponibles'] as int? ?? 0;

        if (availableSeats < seats) {
          throw Exception("Pas assez de places disponibles");
        }

        // Read Chauffeur
        final driverRef = FirebaseFirestore.instance.collection('Chauffeur').doc(trajetData['chauffeurId']);
        final driverDoc = await transaction.get(driverRef);
        if (!driverDoc.exists) {
          throw Exception("Chauffeur non trouvé");
        }

        // Update Trajet
        transaction.update(trajetRef, {
          'placesDisponibles': FieldValue.increment(-seats),
          'placesReservees': FieldValue.increment(seats),
        });

        if (driverDoc['abonnementActif'] == false) {
          // Update Chauffeur solde
          transaction.update(driverRef, {
            'solde': FieldValue.increment(-driverCommission),
          });

          transaction.update(driverRef, {
            'historiqueTransactions': FieldValue.arrayUnion([
              {
                'type': 'Réservation : ${userData['nom']} a réservé votre trajet ${trajetData['depart'] ?? 'N/A'} → ${trajetData['destination'] ?? 'N/A'}',
                'montant': driverCommission,
                'date': Timestamp.now(),
              }
            ]),
          });
        }

        // Create Reservation
        transaction.set(reservationRef, {
          'clientId': userId,
          'clientNom': userData['nom'] ?? '',
          'clientPrenom': userData['prenom'] ?? '',
          'clientPhone': userData['phone'] ?? '',
          'trajetId': trajetId,
          'chauffeurId': trajetData['chauffeurId'] ?? '',
          'chauffeurNom': driverData['nom'] ?? '',
          'chauffeurPrenom': driverData['prenom'] ?? '',
          'chauffeurPhone': driverData['phone'] ?? '',
          'seats': seats,
          'price': totalPrice,
          'date': Timestamp.now(),
          'status': 'pending',
        });

        // Create Notification for Driver
        transaction.set(
          FirebaseFirestore.instance.collection('Notifications').doc(),
          {
            'chauffeurId': trajetData['chauffeurId'] ?? '',
            'message':
                'Nouvelle réservation pour votre trajet ${trajetData['depart'] ?? 'N/A'} → ${trajetData['destination'] ?? 'N/A'} '
                'par ${userData['nom'] ?? 'N/A'} ${userData['prenom'] ?? ''} '
                '(${seats} place${seats > 1 ? 's' : ''}). '
                'Téléphone: ${userData['phone'] ?? 'N/A'}. '
                'Point de ramassage: ${trajetData['pickupPoint'] ?? 'N/A'}. '
                'Statut: pending. '
                'Prix total: $totalPrice DZD.',
            'timestamp': Timestamp.now(),
            'read': false,
            'type': 'reservation',
            'reservationId': reservationId,
          },
        );
      });

      // Show success dialog
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            "Réservation réussie",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Text(
                  "Votre réservation pour ${trajetData['depart'] ?? 'N/A'} → ${trajetData['destination'] ?? 'N/A'} a été confirmée.",
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  "Chauffeur: ${driverData['nom'] ?? 'N/A'} ${driverData['prenom'] ?? ''}",
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  "Téléphone: ${driverData['phone'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ReservationsPage(userId: userId),
                  ),
                );
              },
              child: Text(
                "Voir mes réservations",
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Reservation error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de la réservation : ${e.toString()}",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: CupertinoColors.destructiveRed,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color.fromARGB(255, 237, 243, 250),
      appBar: AppBar(
        title: Text(
          'Résultats de recherche',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF09183F),
        
      ),
      body: searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.car_detailed,
                    size: 64,
                    color: CupertinoColors.systemGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Aucun trajet trouvé",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final trajet = result['trajet'] as Map<String, dynamic>;
                final driver = result['driver'] as Map<String, dynamic>;
                final date = (trajet['dateDepart'] as Timestamp?)?.toDate();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 300 + index * 100),
                    child: Card(
                      elevation: 0,
                      color: CupertinoColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                                    "${trajet['depart'] ?? 'N/A'} → ${trajet['destination'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${trajet['placesDisponibles']?.toString() ?? '0'} places",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildInfoRow(
                              icon: CupertinoIcons.person,
                              text: "Chauffeur: ${driver['nom'] ?? 'N/A'} ${driver['prenom'] ?? ''}",
                            ),
                            _buildInfoRow(
                              icon: CupertinoIcons.phone,
                              text: "Téléphone: ${driver['phone'] ?? 'N/A'}",
                            ),
                            _buildInfoRow(
                              icon: CupertinoIcons.calendar,
                              text: "Date: ${date != null ? DateFormat('dd MMM yyyy, HH:mm').format(date) : 'Non spécifiée'}",
                            ),
                            _buildInfoRow(
                              icon: CupertinoIcons.location,
                              text: "Point de ramassage: ${trajet['pickupPoint'] ?? 'N/A'}",
                            ),
                            _buildInfoRow(
                              icon: CupertinoIcons.info,
                              text: "Remarque: ${trajet['remarque']?.isEmpty ?? true ? 'Aucune' : trajet['remarque']}",
                            ),
                            _buildInfoRow(
                              icon: CupertinoIcons.money_dollar,
                              text: "Prix: ${trajet['prixParPassager']?.toString() ?? '0'} DZD/pers.",
                            ),
                            SizedBox(height: 16),
                            CupertinoButton(
                              onPressed: () => reserveRide(context, result['trajetId'], trajet, driver),
                              padding: EdgeInsets.zero, // Enlève le padding par défaut
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF09183F), // Couleur principale du bouton
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Réserver ($seats place${seats > 1 ? 's' : ''})",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.black.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
