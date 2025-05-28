import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/Inscrimption_Screen/inscription_widget.dart';
import 'package:myproject/Profil_Screen/Home_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const CodeVerificationPage({super.key, required this.verificationId, required this.phoneNumber});

  static const String routeName = '/codeVerification';
  static const String routePath = '/codeVerification';

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


    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('Uid', FirebaseAuth.instance.currentUser!.uid);
    print(FirebaseAuth.instance.currentUser!.uid);


    final String phoneNumber = widget.phoneNumber;

    // Requête Firestore pour chercher l'utilisateur par numéro
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

    if (snapshot.exists) {
      // Utilisateur trouvé → aller au profil
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeWidget(userId: FirebaseAuth.instance.currentUser!.uid,)));
    } else {
      // Utilisateur non trouvé → aller à l'inscription
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => InscriptionWidget(userId: FirebaseAuth.instance.currentUser!.uid, phoneNumber : phoneNumber)));
    }

  } catch (e) { 
    String errorMessage = 'Erreur inconnue';

if (e is FirebaseAuthException) {
  switch (e.code) {
    case 'invalid-verification-code':
      errorMessage = 'Code invalide.';
      break;
    case 'session-expired':
      errorMessage = 'Session expirée. Veuillez réessayer.';
      break;
    default:
      errorMessage = e.message ?? 'Erreur inattendue.';
  }
} else {
  errorMessage = 'Une erreur s\'est produite.';
}

ScaffoldMessenger.of(context)
    .showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF09183F),
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
            const SizedBox(height: 24),
            Text(
              'Saisir le code reçu par SMS',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 20,
                color: const Color(0xFF09183F),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Un code à 6 chiffres a été envoyé au ${widget.phoneNumber}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 24,
                color: const Color(0xFF09183F),
              ),
              decoration: InputDecoration(
                hintText: '• • • • • •',
                hintStyle: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[400],
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF09183F)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF09183F), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonDisabled
                    ? null
                    : () {
                        setState(() {
                          _isButtonDisabled = true;
                        });
                        verifyCode();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF09183F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Valider',
                  style: GoogleFonts.anton(
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