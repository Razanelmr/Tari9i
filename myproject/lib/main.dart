import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/Phone_Page/Phone_Screen.dart';
import 'package:myproject/Profil_Screen/Home_Screen.dart';
import 'package:myproject/Profil_Screen/covoiturage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userId = prefs.getString('Uid');

  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;

  const MyApp({super.key, required this.isLoggedIn, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tari9i',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: isLoggedIn && userId!= null
          ? HomeWidget(userId: userId!)
          : HomePage(),

          // ✅ Ajoute cette ligne pour déclarer tes routes nommées
      routes: {
        PhoneNumberPage.routeName: (context) => PhoneNumberPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/homePage';
  static const String routePath = '/homePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Offset> _imagePositionAnimation;
  late Animation<double> _imageOpacityAnimation;
  late Animation<double> _imageScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _titleAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _subtitleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    _imagePositionAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _imageScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SlideTransition(
                position: _titleAnimation,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 30, 0),
                  child: Text(
                    'TARI9I',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.anton(
                      fontSize: 100,
                      color: const Color(0xFF09183F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _subtitleAnimation,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 30, 20),
                  child: Text(
                    'Moins de frais, plus de compagnie.',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: const Color(0xFF09183F),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _buttonAnimation,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(170, 0, 30, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, PhoneNumberPage.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF09183F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      fixedSize: const Size(150, 76),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Suivant',
                          style: GoogleFonts.interTight(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 24,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _imageOpacityAnimation,
                child: SlideTransition(
                  position: _imagePositionAnimation,
                  child: ScaleTransition(
                    scale: _imageScaleAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/Voiture.png',
                        width: double.infinity,
                        height: 325,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
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