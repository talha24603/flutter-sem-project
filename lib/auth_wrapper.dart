import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/login.dart';
import 'package:semester_project/main.dart';
import 'services/shared_preferences_service.dart';

import 'admin_dashboard.dart';
import 'complaint_form.dart';

class AuthWrapper extends StatefulWidget {
  final String? targetPage;

  const AuthWrapper({Key? key, this.targetPage}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userType = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      print('Starting auth initialization...');

      // Ensure SharedPreferences is initialized
      if (!SharedPreferencesService.isInitialized) {
        print('Initializing SharedPreferences...');
        await SharedPreferencesService.init();
      }

      // Get current Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      print('Firebase user: ${firebaseUser?.email ?? 'null'}');

      // Get stored login state
      bool storedLoginState = SharedPreferencesService.isLoggedIn;
      String storedUserType = SharedPreferencesService.userType;
      print('Stored login state: $storedLoginState, type: $storedUserType');

      // Determine final auth state
      if (firebaseUser != null && storedLoginState) {
        // User is authenticated in both Firebase and local storage
        try {
          await firebaseUser.reload(); // Verify user is still valid
          print('User authenticated successfully');

          setState(() {
            _isLoggedIn = true;
            _userType = storedUserType;
            _isLoading = false;
          });
          return;
        } catch (e) {
          print('Firebase user reload failed: $e');
          // User token might be expired, clear local data
          await _clearAuthData();
        }
      } else if (firebaseUser != null && !storedLoginState) {
        // Firebase user exists but no local data - sign out Firebase
        print('Firebase user exists but no local data, signing out...');
        await FirebaseAuth.instance.signOut();
        await _clearAuthData();
      } else if (firebaseUser == null && storedLoginState) {
        // Local data exists but no Firebase user - clear local data
        print('Local data exists but no Firebase user, clearing...');
        await _clearAuthData();
      } else {
        // No authentication anywhere
        print('No authentication found');
        await _clearAuthData();
      }

    } catch (e) {
      print('Error during auth initialization: $e');
      setState(() {
        _errorMessage = 'Authentication error: ${e.toString()}';
        _isLoading = false;
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await SharedPreferencesService.clearUserData();
      setState(() {
        _isLoggedIn = false;
        _userType = '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error clearing auth data: $e');
      setState(() {
        _isLoggedIn = false;
        _userType = '';
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Checking authentication...'),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = '';
                    _isLoading = true;
                  });
                  _initializeAuth();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getTargetPage() {
    // If a specific target page is requested
    if (widget.targetPage != null) {
      switch (widget.targetPage) {
        case 'complaint_form':
          return const ComplaintForm();
        case 'admin_dashboard':
          return const AdminDashboard();
        case 'main_page':
          return const MyApp();
        default:
          break;
      }
    }

    // Default navigation based on user type
    if (_userType == 'admin') {
      return const AdminDashboard();
    } else {
      return const MyApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AuthWrapper build - Loading: $_isLoading, LoggedIn: $_isLoggedIn, UserType: $_userType');

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_isLoggedIn) {
      return const LoginPage();
    }

    return _getTargetPage();
  }
}
