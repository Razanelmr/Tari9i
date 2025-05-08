import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/Inscrimption_Screen/inscription_widget.dart';
import 'package:myproject/Profil_Screen/Autorisation.dart';
import 'package:myproject/Profil_Screen/Home_Screen.dart';

class CodeVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  CodeVerificationPage({required this.verificationId, required this.phoneNumber});

  @override
  _CodeVerificationPageState createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isButtonDisabled = false;

  Future<void> verifyCode() async {
  final credential = PhoneAuthProvider.credential(
    verificationId: widget.verificationId,
    smsCode: _codeController.text.trim(),
  );

  try {
    // Connexion avec le code SMS
    await FirebaseAuth.instance.signInWithCredential(credential);

    final String phoneNumber = widget.phoneNumber;

    // Requête Firestore pour chercher l'utilisateur par numéro
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Utilisateur trouvé → aller au profil
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AutoriseLocalisationWidget(phoneNumber: phoneNumber,)));
    } else {
      // Utilisateur non trouvé → aller à l'inscription
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => InscriptionWidget(phoneNumber: phoneNumber,)));
    }

  } catch (e) { 
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF09183F),
        elevation: 0,
        title: Text(
          'Vérifier le code',
          style: GoogleFonts.anton(
                    fontSize: 20,
                    color: const Color(0xFF09183F),
                    fontWeight: FontWeight.w500,
                  ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Center(
              child: Text(
              'Saisir le code reçu par SMS',
              style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: const Color(0xFF09183F),
                    fontWeight: FontWeight.w800,
                  ),
                  
                  
            ),
            ),
            SizedBox(height: 8),
            Text(
              'Un code à 6 chiffres a été envoyé au ${widget.phoneNumber}. Veuillez le saisir ci-dessous.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Roboto',
                color: Color(0xFF09183F),
              ),
              decoration: InputDecoration(
                hintText: '• • • • • •',
                hintStyle: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[400],
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF09183F)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF09183F), width: 2),
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonDisabled
                        ? null // Bouton désactivé après le clic
                        : () {
                              setState(() {
                                _isButtonDisabled = true; // Désactive le bouton après le clic
                              });
                              verifyCode(); // Appelle ta fonction sans reactive le bouton
                          
                          },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF09183F),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Valider',
                  style: TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'En créant le compte vous acceptez politiques et stratégies de l’utilisation',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}