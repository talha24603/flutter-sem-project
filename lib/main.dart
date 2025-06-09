import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/login.dart';
import 'services/shared_preferences_service.dart';
import 'main_page.dart';
import 'admin_dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  await SharedPreferencesService.init();

  // Set system UI
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CUI Complaints',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF005D99),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005D99),
          primary: const Color(0xFF005D99),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SimpleAuthCheck(),
    );
  }
}

class SimpleAuthCheck extends StatefulWidget {
  const SimpleAuthCheck({Key? key}) : super(key: key);

  @override
  State<SimpleAuthCheck> createState() => _SimpleAuthCheckState();
}

class _SimpleAuthCheckState extends State<SimpleAuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // Wait a moment for everything to initialize
    await Future.delayed(const Duration(seconds: 1));

    // Check if user is logged in
    bool isLoggedIn = SharedPreferencesService.isLoggedIn;
    String userType = SharedPreferencesService.userType;
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    print('Logged in: $isLoggedIn, Type: $userType, Firebase: ${firebaseUser?.email}');

    Widget nextPage;

    if (isLoggedIn && firebaseUser != null && userType.isNotEmpty) {
      // User is logged in - go to appropriate page
      if (userType == 'admin') {
        nextPage = const AdminDashboard();
      } else {
        nextPage = const MainPage();
      }
    } else {
      // User not logged in - go to login
      nextPage = const LoginPage();
    }

    // Navigate to the determined page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3F51B5),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.school,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'COMSATS University',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
