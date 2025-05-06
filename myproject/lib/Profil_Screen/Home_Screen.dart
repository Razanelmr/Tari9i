import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});
  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;
  String? choiceChipsValue; // État pour suivre la sélection
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Color borderColor = Color(0xFF09183F);
late Future<DocumentSnapshot?> userDataFuture;
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
    choiceChipsValue = 'Réservez Ultérieurement'; // Valeur initiale
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String phoneNumber = args?['phoneNumber'] ?? '';

    // Charger les données dès l'initialisation
    userDataFuture = getUserData(phoneNumber);
  }

  // 🔍 Fonction corrigée pour récupérer les données
  Future<DocumentSnapshot?> getUserData(String phoneNumber) async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(phoneNumber);

    try {
      final DocumentSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        return snapshot; // Retourne les données si le doc existe
      } else {
        return null; // Le document n'existe pas
      }
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Color(0xFF09183F),
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 6, 0, 6),
            child: Container(
              width: 70.01,
              height: 70.01,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    'https://picsum.photos/seed/626/600',
                    width: 323.3,
                    height: 224.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            'Hey Jenny',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: FutureBuilder<DocumentSnapshot?>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Aucun utilisateur trouvé."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String nom = userData['nom'] ?? 'Non défini';
          final String prenom = userData['prenom'] ?? 'Non défini';
          final String email = userData['email'] ?? 'Non défini';
          final String phoneNumber = userData['phone'] ?? 'Non défini';

          return SafeArea(
          top: true,
          child: CustomScrollView(
            slivers: [
              // Header container
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Color(0xFF09183F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Top Row: Phone and Points
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(35, 0,35, 0),
                        child: Row(
                          
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.white,size: 15,),
                                  SizedBox(width: 15,),
                                  Text(
                                        phoneNumber,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontFamily:
                                                  GoogleFonts.inter().fontFamily,
                                              fontSize: 15,
                                            ),
                                      ),
                                ],
                              )
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                icon: Icon(Icons.workspace_premium, color: Colors.white,
                                size: 15,
                                ),
                                onPressed: () {},
                                ),
                                Text(
                                  '0 Points',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                        fontFamily:
                                            GoogleFonts.inter().fontFamily,
                                        fontSize: 15
                                      ),
                                ),
                                
                              ],
                            )
                          ],
                        ),
                      ),
                      // "Position Actuelle" Label
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                          child: Text(
                            'Position Actuelle',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: const Color(0xFFCECCCC),
                                  fontSize: 16,
                                  letterSpacing: 0.0,
                                  fontFamily:
                                      GoogleFonts.inter().fontFamily,
                                ),
                          ),
                        ),
                      ),
                      // Location Row
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.white,
                              size: 25,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hello World',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    fontFamily:
                                        GoogleFonts.inter().fontFamily,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Reservation Title
              SliverToBoxAdapter(
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(vertical: 15),
                    child: Text(
                      'Reservation',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Color(0xFF09183F),
                            fontSize: 25,
                            letterSpacing: 0.0,
                            fontFamily: GoogleFonts.anton().fontFamily,
                          ),
                    ),
                  ),
                ),
              ),

              // ChoiceChips
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChoiceChip(
                            label: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text('Ultérieurement'),
                              ],
                            ),
                            selectedColor: Color(0xFF09183F),
                            selected:
                                choiceChipsValue == 'Réservez Ultérieurement',
                            onSelected: (_) {
                              setState(() {
                                choiceChipsValue = 'Réservez Ultérieurement';
                              });
                            },
                            labelStyle: TextStyle(
                              color: choiceChipsValue ==
                                      'Réservez Ultérieurement'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          SizedBox(width: 8),
                          ChoiceChip(
                            label: Row(
                              children: [
                                Icon(Icons.directions_car,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text('Maintenant'),
                              ],
                            ),
                            selectedColor: Color(0xFF09183F),
                            selected:
                                choiceChipsValue == 'Réservez Maintenant',
                            onSelected: (_) {
                              setState(() {
                                choiceChipsValue = 'Réservez Maintenant';
                              });
                            },
                            labelStyle: TextStyle(
                              color:
                                  choiceChipsValue == 'Réservez Maintenant'
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              SliverToBoxAdapter(
                child: Divider(thickness: 1, color: Colors.grey.shade300),
              ),

              // Conditional Content
              if (choiceChipsValue == 'Réservez Ultérieurement')
                ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: textController,
                        focusNode: textFieldFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Cherchez annonce de départ...',
                          suffixIcon: Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF09183F),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF09183F),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Départ Pres de Chez Vous...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF09183F),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 44),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TripCard(),
                        childCount: 6,
                      ),
                    ),
                  )
                ]
              else
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Vous avez choisi : Réservez Maintenant',
                        style: TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          );
  }
  )
      ),
    );
  }
}


class TripCard extends StatelessWidget {
  const TripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFF09183F),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF09183F),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/persone.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UV 01, Ali Mandjeli',
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'chauffeur',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                      Text(
                      ' Point départ : ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                      ),
                    Row(
                      children: [
                        Icon(
                          Icons.start_outlined,
                          size: 15,
                        ),
                        Text(
                        ' Sidi Mebrouk Superieur.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF0D6552),
                        ),
                      ),
                      ],
                    ),
                    
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: Colors.black54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '07:45am',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () {
                            print('Button pressed ...');
                          },
                          text: 'Réservez',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Custom Button Widget ---
class FFButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const FFButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF09183F),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minimumSize: const Size(40, 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.interTight(
          fontSize: 10,
          fontWeight: FontWeight.normal,
        ),
      ),
      child: Text(text),
    );
  }
}