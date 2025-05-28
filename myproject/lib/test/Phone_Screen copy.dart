import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myproject/Phone_Page/code_verification.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  static const String routeName = '/phonePage';
  static const String routePath = '/phonePage';

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  bool _isButtonDisabled = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  DateTime? _lastClickTime;

Future<void> sendOtp() async {
  final phone = '+213${_phoneController.text.trim()}';
  final response = await http.post(
    Uri.parse("https://ee97-129-45-115-96.ngrok-free.app/send-otp"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phoneNumber': phone}),
  );

  print('sendOtp response: ${response.body}');
}
  void _onSendCodePressed() {
    final now = DateTime.now();

    // Protection contre les clics multiples rapides
    if (_lastClickTime == null || now.difference(_lastClickTime!) > const Duration(seconds: 2)) {
      _lastClickTime = now;

      if (_formKey.currentState!.validate()) {
        setState(() {
          _isButtonDisabled = true;
        });

        // Afficher un loader
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        sendOtp().then((_) {
          // Déjà géré dans sendCode()
        }).catchError((error) {
          setState(() {
            _isButtonDisabled = false;
          });
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Veuillez patienter...")));
    }
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bonjour..',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anton(
                      fontSize: 45,
                      color: const Color(0xFF09183F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Entrez votre numéro de téléphone',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 19,
                      color: const Color(0x9509183F),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                height: 30,
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
                              child: Form(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ElevatedButton(
                      onPressed: (){
                        sendOtp();
                      
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF09183F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Envoyez le code',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
      ),
    );
  }
}