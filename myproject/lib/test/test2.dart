import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilPage(),
    );
  }
}

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MON PROFIL',
          style: TextStyle(
            color: Colors.pink,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section : Nom et Prénom
            ListTile(
              leading: Icon(Icons.person, color: Colors.pink),
              title: Text(
                'Razane',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Lmr',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Divider(color: Colors.grey[300]),

            // Section : Numéro de téléphone
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/flag.png', // Remplacez par votre icône de drapeau
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '+213',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '0558094661',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[300]),

            // Section : Email
            ListTile(
              leading: Icon(Icons.email, color: Colors.pink),
              title: Text(
                'razzanelmr8@gmail.com',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Divider(color: Colors.grey[300]),

            // Bouton Enregistrer
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[200],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Enregistrer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Paramètres d'accessibilité
            ListTile(
              leading: Icon(Icons.accessibility, color: Colors.purple),
              title: Text(
                'Paramètres d\'accessibilité',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
            ),
            Divider(color: Colors.grey[300]),

            // Modifier le mot de passe
            ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text(
                'Modifier mon mot de passe',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            Divider(color: Colors.grey[300]),

            // Déconnexion
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
              title: Text(
                'Déconnecter',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}