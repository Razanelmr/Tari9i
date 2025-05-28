import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:myproject/Profil_Screen/Home_Screen.dart';

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

  Future<void> verifierOtpEtSeConnecter(String phoneNumber, String otp) async {
    print("Envoi requête pour vérifier OTP...");
    final response = await http.post(
      Uri.parse("https://b78a-129-45-115-96.ngrok-free.app/verify-otp"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      await FirebaseAuth.instance.signInWithCustomToken(token);
      print("Connecté !");
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception("Erreur de vérification : $error");
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
                    : () async {
                        setState(() => _isButtonDisabled = true);

                        try {
                          await verifierOtpEtSeConnecter(
                              widget.phoneNumber, _codeController.text);
                          // Si succès, naviguer vers HomeScreen
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>  HomeWidget(userId: FirebaseAuth.instance.currentUser!.uid,)),
                            );
                          }
                        } catch (e) {
                          // Afficher une alerte en cas d'erreur
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Erreur"),
                              content: Text(e.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } finally {
                          setState(() => _isButtonDisabled = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF09183F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isButtonDisabled
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
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
