import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Pour les validateurs

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
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
                              child: Image.network(
                                'https://img.icons8.com/?size=100&id=ohQGuW5WrzUc&format=png&color=000000',
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
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                    StartingZeroFormatter(),
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
                                    if (value.length != 10) {
                                      return 'Le numéro doit contenir 10 chiffres';
                                    }
                                    if (!value.startsWith('0')) {
                                      return 'Le numéro doit commencer par 0';
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
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Numéro valide, faire quelque chose
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Numéro valide: ${_textController.text}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: Text(
                      'Envoyez le code',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
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


  // Valideur personnalisé : commence par 0
  class StartingZeroFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue, TextEditingValue newValue) {
      final newText = newValue.text;

      if (newText.isEmpty ||
          (newText.startsWith('0') && RegExp(r'^\d*$').hasMatch(newText))) {
        return newValue;
      }
      return oldValue;
    }
  }
