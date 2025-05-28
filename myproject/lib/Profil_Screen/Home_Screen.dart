import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myproject/Profil_Screen/MenuPage.dart';
import 'package:myproject/Profil_Screen/address_search_screen.dart';
import 'package:myproject/Profil_Screen/covoiturage.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeWidget extends StatefulWidget {
  String userId;
  HomeWidget({Key? key, required this.userId}) : super(key: key);
  static String routePath = '/home';

  static const String routeName = '/HomeWidget'; // ✅ Ajout de la route nommée

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool _isPaymentModalShown = false;
  late Future<void> _userDataFuture;
  bool _isLoading = true;
  dynamic _userData;
  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _phone = '';
  late TextEditingController _departureController;
  late TextEditingController _destinationController;
  
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;
  String? choiceChipsValue; // État pour suivre la sélection
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Color borderColor = Color(0xFF09183F);
  late GoogleMapController mapController;
  final TextEditingController _controller = TextEditingController();
  Position? _currentPosition;
  LatLng? _selectedDestination;
  LatLng? _selectedDepart;
  Set<Polyline> _polylines = {};
  bool _waitingForDriver = false;
  int _tripPrice = 0;


    late TextEditingController depart;
    late TextEditingController destination;
    late TextEditingController DateReservation;

  late FocusNode _departFocusNode1;
  late FocusNode _destinationFocusNode2;


  int _count = 1; // Compteur initial

  void _incrementCount() {
    setState(() {
      _count++;
    });
  }

  void _decrementCount() {
    if (_count > 0) {
      setState(() {
        _count--;
      });
    }
  }







  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
    choiceChipsValue = 'Réservez Ultérieurement';
    // Init controllers for departure & destination
    _departureController = TextEditingController(text: "Votre position actuelle");
    _destinationController = TextEditingController();

    depart = TextEditingController();
    _departFocusNode1 = FocusNode();

    destination = TextEditingController();
    _destinationFocusNode2 = FocusNode();

    DateReservation = TextEditingController();



  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    textFieldFocusNode.dispose();

    depart.dispose();
    _departFocusNode1.dispose();
    destination.dispose();
    _destinationFocusNode2.dispose();

    DateReservation.dispose();

    super.dispose();
  }

Future<bool> _onWillPopScope(BuildContext context) async {
    final shouldPop = await _showCancelTripDialog(context);
    return shouldPop; // Si true, on permet la navigation en arrière
  }

  Future<bool> _showCancelTripDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        
        title: Text('ANNULER LE TRAJET?',style : GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),),
        content: Text(
            'Si vous annulez ce trajet pour en commander un nouveau à la suite, vous risquez d’attendre plus longtemps.',
            textAlign: TextAlign.justify,
            ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('NON', style: TextStyle(color: Color(0xFF09183F))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF09183F)),
            onPressed: () {
              Navigator.of(context).pop(true); // true = autorise pop
            },
            child: Text('OUI', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
    return result ?? false;
  }


  Future<void> fetchUserData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF09183F),
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
            _nom.isEmpty && _prenom.isEmpty
                ? ""
                : "${_nom.toUpperCase()} ${_prenom[0].toUpperCase()}${_prenom.substring(1).toLowerCase()}",
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
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 400),
                      pageBuilder: (_, __, ___) => MenuPage(userId: widget.userId,),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0), // Commence de la gauche
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
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
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _PinnedHeaderDelegate(
                  child: Container(
                    color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      height: 70,
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
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(35, 0, 35, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone, color: Colors.white, size: 15),
                                      SizedBox(width: 15),
                                      Text(
                                        _phone,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontFamily: GoogleFonts.inter().fontFamily,
                                              fontSize: 15,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.workspace_premium, color: Colors.white, size: 15),
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
                                            fontFamily: GoogleFonts.inter().fontFamily,
                                            fontSize: 15,
                                          ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _PinnedHeaderDelegateTitle(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 10),
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
              SliverPersistentHeader(
                pinned: false,
                delegate: _ChoiceChipHeaderDelegate(
                  child: Container(
                    height: 50,
                    color: Colors.white,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChoiceChip(
                                label:
                                    Text('Ultérieurement',style: TextStyle(fontSize: 10),),
                                  
                                selectedColor: Color(0xFF09183F),
                                selected: choiceChipsValue == 'Réservez Ultérieurement',
                                onSelected: (_) {
                                  setState(() {
                                    choiceChipsValue = 'Réservez Ultérieurement';
                                  });
                                },
                                labelStyle: TextStyle(
                                  color: choiceChipsValue == 'Réservez Ultérieurement'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                              ),
                              SizedBox(width: 8),
                              ChoiceChip(
                                label: 
                                    Text('Maintenant', style: TextStyle(fontSize: 10),),

                                selectedColor: Color(0xFF09183F),
                                selected: choiceChipsValue == 'Réservez Maintenant',
                                onSelected: (_) {
                                  setState(() {
                                    choiceChipsValue = 'Réservez Maintenant';
                                  });
                                },
                                labelStyle: TextStyle(
                                  color: choiceChipsValue == 'Réservez Maintenant'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                backgroundColor: Color.fromARGB(255, 243, 243, 243),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              
              SliverPersistentHeader(
                pinned: true,
                delegate: _ChoiceChipHeader(
                  child: Container(
                    height: 5,
                    color: Colors.white,
                    child: Divider(thickness: 1, color: Colors.grey.shade300),
                  ),
                ),
              ),


              if (choiceChipsValue == 'Réservez Ultérieurement')
                ...[
                  SliverToBoxAdapter(
                  child: SearchTrajet(userId : widget.userId),
                ),
                  
                ]
              else
                SliverToBoxAdapter(
                  child: buildReserverMaintenant(context),
                ),
            ],
          ),
        ),
      ),
    );
  }


Widget buildReserverUlterieur(BuildContext context) {
  return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    },
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
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
          padding: const EdgeInsets.all(20.0),
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
                                focusNode: _departFocusNode1,
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
                                  focusNode: _destinationFocusNode2,
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
                              controller: DateReservation,
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
                                  DateReservation.text =
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Date requise';
                                }
                                final date = DateTime.tryParse(value);
                                if (date == null ||
                                    date.isBefore(DateTime.now())) {
                                  return 'Veuillez choisir une date future';
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

                Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Text("Nombre de places que vous souhaitez réserver"),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _decrementCount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: CircleBorder(),
                              ),
                              child: Icon(Icons.remove, color: Colors.white),
                            ),
                            SizedBox(width: 30),
                            Text(
                              '$_count',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 30),
                            ElevatedButton(
                              onPressed: _incrementCount,
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
                              onPressed: () {
                                print('click');
                              },
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
  );
}


  Widget buildReserverMaintenant(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(0, 0),
              zoom: _currentPosition != null ? 15 : 2,
            ),
            markers: {
              if (_selectedDestination != null)
                Marker(
                  markerId: MarkerId("dest"),
                  position: _selectedDestination!,
                  infoWindow: InfoWindow(title: "Destination"),
                ),
            },
            myLocationEnabled: true,
            polylines: _polylines,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          color: Colors.white,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressSearchScreen(
                    currentPosition: _currentPosition,
                  ),
                ),
              );
              if (result != null && result is Map<String, String>) {
                setState(() {
                  _destinationController.text = result['destination']!;
                });
                _getDestinationCoordinates(result['destination']!, result['departure']!);
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: "Destination",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_tripPrice > 0 && _waitingForDriver)
          Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _isPaymentModalShown) return;
                _showPaymentModal(context);
              });
              return SizedBox.shrink();
            },
          ),
      ],
    );
  }

  void _showPaymentModal(BuildContext context) {
    if (_isPaymentModalShown) return;
    _isPaymentModalShown = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _waitingForDriver = false;
                      });
                      _isPaymentModalShown = false;
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    "Vous payez comment ?",
                    style: GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          "Espèces",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      "${_tripPrice.toStringAsFixed(0)} DA",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF09183F),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saRoule(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF09183F),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Continuer",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isPaymentModalShown = false;
    });
  }

  Future<void> _saRoule(BuildContext context) async {
    if (_selectedDestination == null || _currentPosition == null) return;
    String addressDestination = await _getAddressFromPosition(_selectedDestination!.latitude, _selectedDestination!.longitude);
    String addressCurrent = await _getAddressFromPosition(_selectedDepart!.latitude, _selectedDepart!.longitude);
  
  
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () => _onWillPopScope(context),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Rechercher Chauffeur... ",
                    style: GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),
                  ),
                ),
          
                SizedBox(height: 20),
          
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF09183F)),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                  "On confirme votre trajet.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                        Center(
                          child: Icon(Icons.location_on, color: Colors.green),
                        ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                           // Hauteur fixe pour afficher 2 lignes par exemple
                          child: Text(
                            addressCurrent,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
          
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(11, 0, 0, 0),
                    child: Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
                
          
                
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                           // Hauteur fixe pour afficher 2 lignes par exemple
                          child: Text(
                            addressDestination,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isPaymentModalShown = false;
    });
  }

  // ⬇️ SUITE ET FIN DES MÉTHODES CORRECTES (non modifiées pour garder le fichier complet)





Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDisabledDialog(context);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog(context);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog(context);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: currentLatLng, zoom: 15)),
    );
  }

Future<void> _getDestinationCoordinates(String addressDestination , String adresseDepart) async {
    if (addressDestination.isEmpty) return;

    try {
      List<geocoding.Location> locationsDestination = await geocoding.locationFromAddress(addressDestination);
      List<geocoding.Location> locationsDepart = await geocoding.locationFromAddress(adresseDepart);
      if (locationsDestination.isEmpty) {
        _showNoResultDialog(context);
        return;
      }

      if (locationsDestination.length == 1) {
        _centerMapAndDrawRoute(locationsDestination.first, locationsDepart.first);
        return;
      }

      _showLocationOptionsDialog(context, locationsDestination);
    } catch (e) {
      print("Erreur lors de la recherche d'adresse : $e");
      _showErrorDialog(context);
    }
  }

void _centerMapAndDrawRoute(geocoding.Location locationDestination, geocoding.Location locationDepart) async {
  LatLng latLngDestination = LatLng(locationDestination.latitude, locationDestination.longitude);
  LatLng latLngDepart = LatLng(locationDepart.latitude, locationDepart.longitude);
  setState(() {
    _selectedDestination = latLngDestination;
    _selectedDepart = latLngDepart ;
  });
  mapController.animateCamera(
    CameraUpdate.newCameraPosition(CameraPosition(target: latLngDestination, zoom: 15)),
  );
  _drawRoute(latLngDestination);
  if (_currentPosition != null) {
    final double distanceInMeters = Geolocator.distanceBetween(
      latLngDepart.latitude,
      latLngDepart.longitude,
      latLngDestination.latitude,
      latLngDestination.longitude,
    );
    final double distanceInKm = distanceInMeters / 1000;
    final double price = distanceInKm * 45; // Prix au km
    geocoding.Placemark place = await _getAddressFromLatLng(locationDestination.latitude, locationDestination.longitude);
    String displayString = [
      place.name,
      place.thoroughfare,
      place.subThoroughfare,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((s) => s != null && s.trim().isNotEmpty).join(", ");
    setState(() {
      _controller.text = "Votre destination est $displayString";
      _tripPrice = price.toInt() ;
      _waitingForDriver = true;
    });
  }
}

Future<geocoding.Placemark> _getAddressFromLatLng(double lat, double lng) async {
    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
    return placemarks.isNotEmpty ? placemarks.first : geocoding.Placemark();
  }

void _drawRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    final String apiKey = "AIzaSyBUWK0RG1UqNnnoVKQn8VDBq_bxjQC-92c"; // 🔐 Remplace par ta clé API

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin= ${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);

      if (decodedData["routes"].isNotEmpty) {
        var points = decodedData["routes"][0]["overview_polyline"]["points"];
        final List<LatLng> coordinates = decodePolyline(points);

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            points: coordinates,
            color: Colors.blueAccent,
            width: 6,
          ));
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Aucun itinéraire trouvé")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la récupération de l’itinéraire")));
    }
  }

List<LatLng> decodePolyline(String encoded) {
    List<int> bytes = utf8.encode(encoded);
    const int mask = 0xff;
    List<int> result = [];
    int index = 0, lat = 0, lng = 0;

    while (index < bytes.length) {
      int shift = 0, resultCurrent = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        resultCurrent |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((resultCurrent & 1) != 0 ? ~(resultCurrent >> 1) : (resultCurrent >> 1));
      lat += dlat;

      shift = 0;
      resultCurrent = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        resultCurrent |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((resultCurrent & 1) != 0 ? ~(resultCurrent >> 1) : (resultCurrent >> 1));
      lng += dlng;

      result.add(lat);
      result.add(lng);
    }

    List<LatLng> ret = [];
    for (int i = 0; i < result.length; i += 2) {
      ret.add(LatLng((result[i + 1] / 1e5).toDouble(), (result[i] / 1e5).toDouble()));
    }

    return ret;
  }

Future<String> _getAddressFromPosition(double latitude, double longitude) async {
  try {
    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      geocoding.Placemark place = placemarks.first;
      return "${place.street}, ${place.postalCode} ${place.locality}, ${place.country}";
    } else {
      return "Adresse inconnue";
    }
  } catch (e) {
    return "Erreur lors de la récupération de l'adresse";
  }
}

void _showNoResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Aucun résultat", style : GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),),
        content: Text("Adresse introuvable. Vérifiez votre saisie."),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text("OK"))
        ],
      ),
    );
  }

void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Erreur", style : GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),),
        content: Text("Impossible de trouver cette adresse."),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text("Réessayer"))
        ],
      ),
    );
  }

void _showLocationOptionsDialog(
    BuildContext context, List<geocoding.Location> locations) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final loc = locations[index];
          return ListTile(
            title: Text("Coordonnées : ${loc.latitude}, ${loc.longitude}"),
            subtitle: Text("Lieu $index+1"),
            onTap: () async {
              Navigator.of(context).pop();

              if (_currentPosition != null) {
                // Créer un objet Location à partir de _currentPosition
                geocoding.Location departLocation = geocoding.Location(
                  latitude: _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude, 
                  timestamp: DateTime.now(),
                );

                // Appeler la méthode avec les deux paramètres
                _centerMapAndDrawRoute(loc, departLocation);
              } else {
                // Gérer le cas où la localisation actuelle n’est pas disponible
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Impossible d'obtenir votre position actuelle.")),
                );
              }
            },
          );
        },
      );
    },
  );
}

void _showLocationDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Localisation désactivée", style : GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),),
        content: Text("Veuillez activer votre localisation pour utiliser cette fonctionnalité."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _getCurrentLocation(); // Réessayer
            },
            child: Text("Réessayer"),
          ),
        ],
      ),
    );
  }

void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Permission refusée", style : GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),),
        content: Text("La permission de localisation a été refusée."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _getCurrentLocation(); // Réessayer
            },
            child: Text("Réessayer"),
          ),
        ],
      ),
    );
  }

void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Permission bloquée", style : GoogleFonts.anton(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF09183F),
                    ),),
        content: Text("La permission est bloquée. Veuillez l'activer dans les paramètres de l'application."),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Nécessite package:app_settings ou device_info_plus
            },
            child: Text("Paramètres"),
          ),
        ],
      ),
    );
  }
}



//--- Custom Button Widget ---
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
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

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