import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myproject/Phone_Page/Phone_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilPageMod extends StatefulWidget {
  const ProfilPageMod({super.key});

  static String routeName = 'ProfilPageMod';
  static String routePath = '/ProfilPageMod';

  @override
  State<ProfilPageMod> createState() => _ProfilPageModState();
}

class _ProfilPageModState extends State<ProfilPageMod> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<void> _userDataFuture;
  bool _isLoading = true;
  dynamic _userData;

  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _phone = '';
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
    loadPhoneNumber(); // Charger le numéro de téléphone
  }

  Future<void> loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = prefs.getString('phoneNumber');
    });

    if (_phoneNumber != null) {
      _userDataFuture = fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    if (_phoneNumber == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userData = null;
        });
      }
      return;
    }

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_phoneNumber)
          .get();

      if (mounted && userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _isLoading = false;
          _userData = userData;
          _nom = userData?['nom'] ?? 'Non défini';
          _prenom = userData?['prenom'] ?? 'Non défini';
          _email = userData?['email'] ?? 'Non défini';
          _phone = userData?['phone'] ?? 'Non défini';
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _userData = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userData = null;
        });
      }
      print("Erreur lors du chargement des données utilisateur : $e");
    }
  }

  Future<void> updateUserData(String field, String value) async {
    if (_phoneNumber == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_phoneNumber!)
          .update({field: value});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field mis à jour')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour")),
      );
      print("Erreur lors de la mise à jour : $e");
    }
  }

  Widget _buildEditableField({
    required IconData icon,
    required String title,
    required String field, // Champ Firestore
    required String value,
    required Function(String) onSaved,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Color(0xFF09183F)),
      title: Text(title),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.edit, color: Color(0xFF09183F)),
      onTap: () => _showEditDialog(context, field, value, onSaved),
    );
  }

  void _showEditDialog(
      BuildContext context, String field, String currentValue, Function(String) onSaved) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Modifier $field", style: GoogleFonts.anton(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF09183F),
        )),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: "Nouvelle valeur"),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("Annuler", style: TextStyle(color: Color(0xFF09183F))),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                String newValue = controller.text;
                onSaved(newValue);
                updateUserData(field, newValue); // 🔥 Envoi vers Firestore
                Navigator.of(context).pop();
              }
            },
            child: Text("Sauvegarder", style: TextStyle(color: Color(0xFF09183F))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF09183F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MON PROFIL',
          style: TextStyle(
            color: Color(0xFF09183F),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom
            FutureBuilder(
              future: _userDataFuture,
              builder: (context, snapshot) {
                if (_isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildEditableField(
                  icon: Icons.person,
                  title: 'Nom',
                  field: 'nom',
                  value: _nom,
                  onSaved: (value) {
                    setState(() => _nom = value);
                  },
                );
              },
            ),

            Divider(color: Colors.grey[300], height: 1),
            SizedBox(height: 10),

            // Prénom
            _buildEditableField(
              icon: Icons.person_outline,
              title: 'Prénom',
              field: 'prenom',
              value: _prenom,
              onSaved: (value) {
                setState(() => _prenom = value);
              },
            ),

            Divider(color: Colors.grey[300], height: 1),
            SizedBox(height: 10),

            // Téléphone
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image.asset(
                'assets/images/iconAlg.png',
                width: 30,
                height: 30,
              ),
              title: Text(
                'Numéro de téléphone',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                _phone,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Divider(color: Colors.grey[300], height: 1),
            SizedBox(height: 10),

            // Email
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.email, color: Color(0xFF09183F)),
              title: Text('Email'),
              subtitle: Text(
                _email,
                style: TextStyle(color: Colors.grey[600]),
              ),

              onTap: () => _showEditDialog(context, 'email', _email, (value) {
                setState(() => _email = value);
              }),
            ),

            Divider(color: Colors.grey[300], height: 1),
            SizedBox(height: 20),



            
          ],
        ),
      ),

    
      // === BOUTON DÉCONNECTER EN BAS DE PAGE ===
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () async {
            // Action à effectuer lors du clic sur Déconnecter
            await FirebaseAuth.instance.signOut();

            // Optionnel : afficher un message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Déconnecté avec succès')),
            );
            final prefs = await SharedPreferences.getInstance();
            prefs.remove('phoneNumber');

            // Redirection vers la page de login
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhoneNumberPage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
