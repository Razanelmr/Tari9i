import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
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

  Future<void> sendCode() async {
    // Valider à nouveau le formulaire avant envoi
    if (!_formKey.currentState!.validate()) return;

    String phone = '+213${_phoneController.text.trim()}';

    
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 30),
        forceResendingToken: null,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Erreur inconnue';

          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Numéro de téléphone invalide.';
              break;
            case 'quota-exceeded':
              errorMessage = 'Trop de tentatives. Réessayez plus tard.';
              break;
            case 'network-request-failed':
              errorMessage = 'Aucune connexion Internet détectée.';
              break;
            default:
              errorMessage = e.message ?? 'Une erreur est survenue.';
          }

          Navigator.pop(context); // Fermer le loader
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pop(context); // Fermer le loader
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
        codeAutoRetrievalTimeout: (String verificationId) {
          // Optional: Handle timeout
          print('Auto retrieval timed out for $verificationId');
        },
      );
    
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

        sendCode().then((_) {
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
                      onPressed: _isButtonDisabled ? null : _onSendCodePressed,
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