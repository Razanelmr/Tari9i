import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AutoriseLocalisationWidget extends StatefulWidget {
  const AutoriseLocalisationWidget({super.key});

  static String routeName = 'AutoriseLocalisation';
  static String routePath = '/autoriseLocalisation';

  @override
  State<AutoriseLocalisationWidget> createState() =>
      _AutoriseLocalisationWidgetState();
}

class _AutoriseLocalisationWidgetState
    extends State<AutoriseLocalisationWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String phoneNumber = args?['phoneNumber'] ?? '';
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white, // Couleur de fond par défaut
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Texte principal "Autorisation"
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      style: GoogleFonts.anton(
                        fontSize: 45,
                        color: const Color(0xFF09183F),
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                      ),
                      duration: const Duration(milliseconds: 975),
                      curve: Curves.easeIn,
                      child: const Text('Autorisation'),
                    ),
                  ),

                  // Texte secondaire
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: AnimatedDefaultTextStyle(
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          color: Color(0x9509183F),
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeIn,
                        child: const Text(
                          'Veuillez Autoriser Activation de Localisation',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // Bouton "Autoriser"
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(70, 30, 70, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AutoriseLocalisationWidget.routeName,
                            arguments: {'phoneNumber': phoneNumber},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF09183F),
                          foregroundColor: Colors.white,
                          textStyle: GoogleFonts.interTight(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                          ),
                          minimumSize: const Size(double.infinity, 76),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Autoriser'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}