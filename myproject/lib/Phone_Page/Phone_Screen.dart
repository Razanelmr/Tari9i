import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:myproject/Phone_Page/code_verification.dart'; // Pour les validateurs

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  
  void sendCode() async {
    String phone = '+213${_phoneController.text.trim()}';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto login possible ici
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodeVerificationPage(
              verificationId: verificationId,
              phoneNumber: phone,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Primary background color
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                  'Bonjour..',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.anton(
                    fontSize: 45,
                    color: const Color(0xFF09183F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Créez Votre Compte',
                      style: GoogleFonts.roboto(
                    fontSize: 19,
                    color: Color(0x9509183F),
                    fontWeight: FontWeight.normal,
                  ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white, // Secondary background
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF09183F),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/iconAlg.png',
                                width: 45,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const VerticalDivider(
                            thickness: 2,
                            color: Color(0xFF09183F),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Form( // ✅ Ajout du widget Form
                                key: _formKey,
                                child: TextFormField(
                                  controller: _phoneController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Entrez votre numéro',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer un numéro';
                                    }
                                    if (value.length != 9) {
                                      return 'Le numéro doit contenir 9 chiffres';
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
                  ),
                  

                  // Bouton d'envoi
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendCode();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color(0xFF09183F),
                      elevation: 0,
                    ),
                    child: Text(
                      'Envoyez le code',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                  
                ],
              ),

              // Footer
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
      ),
    );
  }
}