import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myproject/Profil_Screen/ReservationsPage.dart';
import 'package:myproject/Profil_Screen/searchresult.dart';

class SearchTrajet extends StatefulWidget {
  final String userId;

  const SearchTrajet({super.key, required this.userId});

  @override
  State<SearchTrajet> createState() => _SearchTrajetState();
}

class _SearchTrajetState extends State<SearchTrajet> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  late TextEditingController depart;
  late TextEditingController destination;
  late TextEditingController dateReservation;
  late FocusNode departFocusNode;
  late FocusNode destinationFocusNode;
  int count = 1;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    print("Current user: ${FirebaseAuth.instance.currentUser?.uid}, Widget userId: ${widget.userId}");
    if (FirebaseAuth.instance.currentUser == null || FirebaseAuth.instance.currentUser!.uid != widget.userId) {
      print("Warning: User not authenticated or userId mismatch");
    }
    depart = TextEditingController();
    destination = TextEditingController();
    dateReservation = TextEditingController();
    departFocusNode = FocusNode();
    destinationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    depart.dispose();
    destination.dispose();
    dateReservation.dispose();
    departFocusNode.dispose();
    destinationFocusNode.dispose();
    super.dispose();
  }

  void incrementCount() {
    setState(() {
      count++;
    });
  }

  void decrementCount() {
    if (count > 1) {
      setState(() {
        count--;
      });
    }
  }

  Future<void> searchRides() async {
    if (!formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté pour rechercher")),
      );
      return;
    }

    setState(() {
      isSearching = true;
    });

    print("Searching with: depart=${depart.text}, destination=${destination.text}, date=${dateReservation.text}, count=$count");

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('Trajets')
          .where('placesDisponibles', isGreaterThanOrEqualTo: count)
          .where('dateDepart', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .where('statut', isEqualTo: 'actif');

      if (depart.text.isNotEmpty) {
        query = query.where('depart', isEqualTo: depart.text.trim());
      }

      if (destination.text.isNotEmpty) {
        query = query.where('destination', isEqualTo: destination.text.trim());
      }

      if (dateReservation.text.isNotEmpty) {
        try {
          final selectedDate = DateFormat('yyyy-MM-dd').parse(dateReservation.text);
          final startOfDay =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));
          query = query
              .where('dateDepart',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('dateDepart', isLessThan: Timestamp.fromDate(endOfDay));
          print("Date filter: start=$startOfDay, end=$endOfDay");
        } catch (e) {
          print("Date parsing error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Format de date invalide")),
          );
          setState(() {
            isSearching = false;
          });
          return;
        }
      }

      final snapshot = await query.get();
      print("Found ${snapshot.docs.length} trajets");

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        final trajetData = doc.data();
        final driverId = trajetData['chauffeurId'] ?? '';
        print("Trajet ID: ${doc.id}, Data: $trajetData");
        if (driverId.isEmpty) {
          print("Skipping trajet with empty driverId");
          continue;
        }

        final driverDoc = await FirebaseFirestore.instance
            .collection('Chauffeur')
            .doc(driverId)
            .get();

        if (driverDoc.exists && driverDoc.data() != null) {
          final driverData = driverDoc.data()!;
          print("Driver ID: $driverId, Data: $driverData");
          results.add({
            'trajetId': doc.id,
            'trajet': trajetData,
            'driver': driverData,
          });
        } else {
          print("Driver not found for ID: $driverId");
        }
      }

      print("Search results: ${results.length} items");
      setState(() {
        isSearching = false;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun trajet trouvé")),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              userId: widget.userId,
              searchResults: results,
              seats: count,
            ),
          ),
        );
      }
    } catch (e) {
      print("Search error: $e");
      setState(() {
        isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la recherche : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    },
    child:  Form(
    key: formKey, // ← AJOUT DE LA CLE DU FORMULAIRE
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: TextButton(
            onPressed: () {
              // Action à exécuter quand on clique sur "reservation"
                Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationsPage(userId : widget.userId)));
            },
            style: ButtonStyle(
              alignment: Alignment.centerRight, // Aligne le contenu à gauche
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero), // Supprime le padding par défaut
            ),
            child: Text(
              'Vos Reservation',
              style: TextStyle(
                decoration: TextDecoration.underline, // Soulignement
                color: Color(0xFF09183F), // Couleur du texte
              ),
              textAlign: TextAlign.right, // Alignement du texte à gauche
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0,0, 0, 0),
          child: Text(
            'Où aimeriez-vous aller?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.anton().fontFamily,
              fontSize: 20,
              letterSpacing: 0.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20,10,20,10),
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: const Color.fromARGB(19, 9, 24, 63),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                          child: Icon(
                            Icons.circle_rounded,
                            color: Color(0xFF09183F),
                            size: 24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: Icon(
                            Icons.keyboard_tab_sharp,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 20, 20, 0),
                            child: SizedBox(
                              width: 200,
                              child: TextFormField(
                                controller: depart,
                                focusNode: departFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  isDense: true,
                                  labelStyle: TextStyle(
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  hintText: 'Départ',
                                  hintStyle: TextStyle(
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                ),
                                style: TextStyle(
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                                cursorColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Veuillez entrer un lieu de départ";
                                  }
                                  return null;
                                },
                              ),
                              
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 70, 0, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                            child: Icon(
                              Icons.circle_rounded,
                              color: Color(0xFF09183F),
                              size: 24,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                            child: Icon(
                              Icons.keyboard_tab_sharp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 20, 20, 0),
                              child: SizedBox(
                                width: 200,
                                child: TextFormField(
                                  controller: destination,
                                  focusNode: destinationFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.inter().fontFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    hintText: 'Destination',
                                    hintStyle: TextStyle(
                                      fontFamily: GoogleFonts.inter().fontFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.error,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.error,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  cursorColor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Veuillez entrer une destination";
                                  }
                                  return null;
                                },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(1, 0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 55, 30, 0),
                        child: IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.longArrowAltDown,
                            color: Colors.white,
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF09183F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            fixedSize: const Size(40, 40),
                          ),
                          onPressed: () {
                            print('IconButton pressed ...');
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(25, 55, 0, 0),
                      child: FaIcon(
                        FontAwesomeIcons.gripLinesVertical,
                        color: Color(0xFF09183F),
                        size: 40,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                          child: Icon(
                            Icons.calendar_today,
                            color: Color(0xFF09183F),
                            size: 24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          child: Icon(
                            Icons.keyboard_tab_sharp,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            size: 24,
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 5, 20, 0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              
                            ),
                            child: TextFormField(
                              controller: dateReservation,
                              readOnly: true,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      DateTime.now().add(const Duration(days: 1)),
                                  firstDate:
                                      DateTime.now().add(const Duration(days: 1)),
                                  lastDate:
                                      DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                            primary: Color(0xFF09183F)),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  dateReservation.text =
                                      "${picked.toLocal()}".split(' ')[0];
                                }
                              },
                              decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.inter().fontFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    hintText: 'Date de reservation',
                                    hintStyle: TextStyle(
                                      fontFamily: GoogleFonts.inter().fontFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.error,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.error,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                              
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Text("Nombre de places que vous souhaitez réserver"),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed:decrementCount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: CircleBorder(),
                              ),
                              child: Icon(Icons.remove, color: Colors.white),
                            ),
                            SizedBox(width: 30),
                            Text(
                              '$count',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 30),
                            ElevatedButton(
                              onPressed: incrementCount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF09183F),
                                shape: CircleBorder(),
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),

                        
                    ],
                    
                  ),
                  ),
                  
                // Supprimé le duplicata de buildDatePicker ici
              ],
            ),
          ),
          
        ),
        Padding(
                          padding: EdgeInsets.fromLTRB(30,0,30,0),
                          child: ElevatedButton(
                              onPressed: isSearching ? null : searchRides,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF09183F),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Rechercher",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          
                          ),
      ],
    ),
    )
    );
  }
}