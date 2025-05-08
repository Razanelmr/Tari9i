import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends StatefulWidget {
  String phoneNumber;
  HomeWidget({Key? key, required this.phoneNumber}) : super(key: key); 
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late Future<void> _userDataFuture;
  bool _isLoading = true;
  dynamic _userData;
  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _phone = '';
  
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;
  String? choiceChipsValue; // État pour suivre la sélection
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Color borderColor = Color(0xFF09183F);

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
    choiceChipsValue = 'Réservez Ultérieurement'; // Valeur initiale

  }

  Future<void> fetchUserData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phoneNumber)
          .get();

      if (mounted && userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _isLoading = false;
          _userData = userData;
          _nom = userData?['nom'] ?? 'Non défini';
          _prenom = userData?['prenom'] ?? 'Non défini';
          _email = userData?['email'] ?? 'Non défini';
          _phone = userData?['phone'] ?? 'Non défini';
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _userData = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userData = null;
        });
      }
      print("Erreur lors du chargement des données utilisateur : $e");
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
                color: Color(0xFF09183F),
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
                  
                  child: Container(
                      width: 20,
                      height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // OR you can use borderRadius:
                      // borderRadius: BorderRadius.circular(50), // half of width/height
                    ),
                    child: Center(
                      child: Text(
                        _nom.isNotEmpty ? _nom[0].toUpperCase() : ' ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            _nom + ' ' + _prenom,
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
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: CustomScrollView(
            slivers: [
              // Header container
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _PinnedHeaderDelegate(
                child: Container(
                  color: Colors.grey[200],
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
                                          _phone,
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
              ),
              ),

              // Reservation Title
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _PinnedHeaderDelegateTitle (
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.symmetric(vertical: 10),
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
                ),
                ),
              

              // ChoiceChips
              SliverPersistentHeader(
                pinned: true,
                delegate: _ChoiceChipHeaderDelegate(
                  child: Container(
                    height: 50,
                    color: Colors.grey[200],
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
                ),
              ),



              SliverPersistentHeader(
            pinned: true,
            delegate: _ChoiceChip(
            child: Container(
              height: 80,
              color: Colors.grey[200],
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
            ),
              ),

              // Divider après les chips
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChoiceChipHeader(
            child: Container(
              height: 5,
              color: Colors.grey[200],
              child : Divider(thickness: 1, color: Colors.grey.shade300),
            )
          ),
          ),



              // Conditional Content
              if (choiceChipsValue == 'Réservez Ultérieurement')
                ...[

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
          ),
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

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}


class _PinnedHeaderDelegateTitle extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedHeaderDelegateTitle({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}


// === Définition du HeaderDelegate pour SliverPersistentHeader ===
class _ChoiceChipHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChoiceChipHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50; // Hauteur maximale du header

  @override
  double get minExtent => 50; // Hauteur minimale si réduit

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      FloatingHeaderSnapConfiguration();
}

// === Définition du HeaderDelegate pour SliverPersistentHeader ===
class _ChoiceChipHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChoiceChipHeader({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 5; // Hauteur maximale du header

  @override
  double get minExtent => 5; // Hauteur minimale si réduit

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      FloatingHeaderSnapConfiguration();
}


// === Définition du HeaderDelegate pour SliverPersistentHeader ===
class _ChoiceChip extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChoiceChip({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 80; // Hauteur maximale du header

  @override
  double get minExtent => 80; // Hauteur minimale si réduit

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      FloatingHeaderSnapConfiguration();
}