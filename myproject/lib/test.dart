import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Pour les validateurs


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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titre
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Bonjour..',
                      style: TextStyle(
                        fontFamily: 'Anton',
                        color: Color(0xFF09183F),
                        fontSize: 45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Sous-titre
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Créez Votre Compte',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0x9509183F),
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Champ de saisie
                  Container(
                    height: 50,
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
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            child: Image(
                              image: NetworkImage(
                                'https://img.icons8.com/?size=100&id=ohQGuW5WrzUc&format=png&color=000000',
                              ),
                              width: 45,
                              height: 45,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5),
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


                        
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

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
                      backgroundColor: const Color(0xFF09183F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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

                  const Spacer(),

                  // Mention légale
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'En créant le compte vous acceptez politiques et stratégies de l’utilisation',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}