import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/Inscrimption_Screen/inscription_widget.dart';
import 'package:myproject/Phone_Page/Phone_Screen.dart';
import 'package:myproject/Profil_Screen/Autorisation.dart';
import 'package:myproject/Profil_Screen/Home_Screen.dart';
import 'package:myproject/test.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white, // Replaced with standard color
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vroom Text
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 30, 0),
                child: Text(
                  'Vroom',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.anton(
                    fontSize: 90,
                    color: const Color(0xFF09183F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Subtitle Text
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 30, 20),
                child: Text(
                  'You Share With Less.',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.roboto(
                    fontSize: 19,
                    color: const Color(0xFF09183F),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              
              // Button
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(170, 0, 30, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeWidget(phoneNumber: '+213558094661',)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09183F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    fixedSize: const Size(double.infinity, 76),
                    textStyle: GoogleFonts.interTight(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Suivant',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      ),
                      SizedBox(width: 3,),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/Voiture.png',
                  width: double.infinity,
                  height: 325,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}