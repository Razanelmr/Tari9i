import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myproject/Profil_Screen/ModificationProfil.dart';
import 'package:myproject/Profil_Screen/ReservationsPage.dart';


class MenuPage extends StatefulWidget {
  final String userId;

  const MenuPage({super.key, required this.userId});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF09183F), // Fond sombre typique d'iOS
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.xmark, color: Colors.white), // Croix blanche
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '', // Aucun titre ici pour garder l'espace vide
          style: TextStyle(color: Colors.transparent),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF09183F), // Fond sombre
              Color(0xFF1A243E), // Graduation légèrement plus claire
            ],
          ),
        ),
        child: ListView(
  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
  children: [
    // MON PROFIL
    InkWell(
      onTap: () {
        // Action à exécuter quand on clique sur "MON PROFIL"
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilPageMod(userId : widget.userId)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'MON PROFIL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
    Divider(color: Colors.white.withOpacity(0.3), height: 1),

    // HISTORIQUE
    InkWell(
      onTap: () {
        // Action à exécuter quand on clique sur "HISTORIQUE"
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'HISTORIQUE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
    Divider(color: Colors.white.withOpacity(0.3), height: 1),

    // PROMOTIONS
    InkWell(
      onTap: () {
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'PROMOTIONS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
    Divider(color: Colors.white.withOpacity(0.3), height: 1),

    // RESERVATION ULTERIEUREMENT
    InkWell(
      onTap: () {
        // Action à exécuter quand on clique sur "MON PROFIL"
        Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationsPage(userId : widget.userId)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'RESERVATION ULTERIEUREMENT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
    Divider(color: Colors.white.withOpacity(0.3), height: 1),

    // AIDE
    InkWell(
      onTap: () {
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'AIDE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
    Divider(color: Colors.white.withOpacity(0.3), height: 1),

    // CENTRE
    InkWell(
      onTap: () {
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'CENTRE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
),
      ),

        bottomNavigationBar: BottomAppBar(
          color: Color(0xFF1A243E),
              child: ElevatedButton(

                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF09183F), // Bleu typique d'iOS
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.car_detailed,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ouvrir l\'application Chauffeur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}