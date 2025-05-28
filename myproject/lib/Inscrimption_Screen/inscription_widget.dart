import 'package:firebase_auth/firebase_auth.dart';
import 'package:myproject/Phone_Page/code_verification.dart';
import 'package:myproject/Profil_Screen/Home_Screen.dart';
import 'package:myproject/models/inscription_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InscriptionWidget extends StatefulWidget {
  String userId;
  String phoneNumber;
  InscriptionWidget({Key? key, required this.userId, required this.phoneNumber}) : super(key: key);
  static String routeName = 'inscription';
  static String routePath = '/inscription';

  @override
  State<InscriptionWidget> createState() => _InscriptionWidgetState();
}

class _InscriptionWidgetState extends State<InscriptionWidget> {
  late InscriptionModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = InscriptionModel();
    _model.textController1 = TextEditingController();
    _model.textController2 = TextEditingController();
    _model.textController3 = TextEditingController();
    _model.textController4 = TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _submitForm(String userId ) async {
    if (_model.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'nom': _model.nom,
          'prenom': _model.prenom,
          'email': _model.email,
          'date_naissance': _model.dateNaissance,
          'phone': widget.phoneNumber,
          'created_at': FieldValue.serverTimestamp(),
        });

        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Informations sauvegardées')),
        );



        // Utilisateur trouvé → aller au profil
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeWidget(userId: widget.userId,)));



      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey, // 🔑 Utilisation du formKey ici
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Text(
                        'Continuez...',
                        style: GoogleFonts.anton(
                          fontSize: 45,
                          color: Color(0xFF09183F),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                        child: Text(
                          'remplissez ces champs',
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            color: Color(0x9509183F),
                          ),
                        ),
                      ),
                    ),
                    // Champ Nom
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xFF09183F), width: 2),
                        ),
                        child: TextFormField(
                          controller: _model.textController1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entrez votre nom';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Entrez Votre Nom',
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ),

                    // Champ Prénom
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xFF09183F), width: 2),
                        ),
                        child: TextFormField(
                          controller: _model.textController2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entrez votre prénom';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Entrez Votre Prénom',
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ),

                    // Champ Email
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xFF09183F), width: 2),
                        ),
                        child: TextFormField(
                          controller: _model.textController3,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email requis';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Entrez Votre Email',
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ),

                    // Champ Date de naissance
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xFF09183F), width: 2),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(primary: Color(0xFF09183F)),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              _model.textController4.text = "${picked.toLocal()}".split(' ')[0];
                            }
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _model.textController4,
                              decoration: InputDecoration(
                                hintText: 'Date de naissance',
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                suffixIcon: Icon(Icons.calendar_today_rounded,
                                    size: 20),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Date de naissance requise';
                                }
                                final date = DateTime.tryParse(value);
                                if (date == null) {
                                  return 'Veuillez choisir une date valide';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Bouton Suivant
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_model.formKey.currentState!.validate()) {
                            _submitForm(widget.userId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF09183F),
                          elevation: 0,
                        ),
                        child: Text(
                          'Suivant',
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

                // Mention légale en bas
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'En créant le compte vous acceptez politiques et stratégies de l’utilisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}