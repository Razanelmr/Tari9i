import 'package:flutter/material.dart';

class InscriptionModel {
  final formKey = GlobalKey<FormState>();

  late TextEditingController textController1; // Nom
  late TextEditingController textController2; // Prénom
  late TextEditingController textController3; // Email
  late TextEditingController textController4; // Date de naissance

  String? get nom => textController1.text.trim();
  String? get prenom => textController2.text.trim();
  String? get email => textController3.text.trim();
  String? get dateNaissance => textController4.text.trim();

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void dispose() {
    textController1.dispose();
    textController2.dispose();
    textController3.dispose();
    textController4.dispose();
  }
}