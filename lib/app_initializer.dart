import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/login.dart';
import 'package:semester_project/main.dart';
import 'services/shared_preferences_service.dart';

import 'admin_dashboard.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  String _status = 'Initializing...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Show splash animation
      setState(() => _status = 'Loading...');
      await Future.delayed(const Duration(seconds: 2));

      // Step 2: Initialize SharedPreferences
      setState(() => _status = 'Initializing preferences...');
      await SharedPreferencesService.init();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Check authentication
      setState(() => _status = 'Checking authentication...');
      await _checkAuthAndNavigate();

    } catch (e) {
      print('App initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _status = 'Initialization failed';
      });
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Get Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      // Get stored preferences
      bool isStoredLoggedIn = SharedPreferencesService.isLoggedIn;
      String storedUserType = SharedPreferencesService.userType;

      print('Firebase user: ${firebaseUser?.email}');
      print('Stored login: $isStoredLoggedIn, type: $storedUserType');

      Widget targetPage;

      if (firebaseUser != null && isStoredLoggedIn && storedUserType.isNotEmpty) {
        // User is authenticated - navigate to appropriate page
        if (storedUserType == 'admin') {
          targetPage = const AdminDashboard();
        } else {
          targetPage = const MyApp();
        }
      } else {
        // User not authenticated - clear any stale data and go to login
        await SharedPreferencesService.clearUserData();
        if (firebaseUser != null) {
          await FirebaseAuth.instance.signOut();
        }
        targetPage = const LoginPage();
      }

      // Navigate to the determined page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => targetPage),
        );
      }

    } catch (e) {
      print('Auth check error: $e');
      // On error, go to login page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _status = 'Retrying...';
    });
    _initializeApp();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 30),

              // University Name
              const Text(
                'COMSATS University',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Islamabad',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 40),

              // App Title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Complaint Management System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Status and Loading
              if (!_hasError) ...[
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _status,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],

              // Error State
              if (_hasError) ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Initialization Failed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
