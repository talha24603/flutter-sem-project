import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/login.dart';
import '../services/shared_preferences_service.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;
  final List<String>? allowedUserTypes; // null means all authenticated users allowed

  const RouteGuard({
    Key? key,
    required this.child,
    this.requireAuth = true,
    this.allowedUserTypes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if authentication is required
    if (!requireAuth) {
      return child;
    }

    // Check if user is authenticated
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    bool isLoggedIn = SharedPreferencesService.isLoggedIn;

    if (!isLoggedIn || firebaseUser == null) {
      // User not authenticated, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      });

      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Redirecting to login...'),
            ],
          ),
        ),
      );
    }

    // Check user type restrictions if specified
    if (allowedUserTypes != null) {
      String userType = SharedPreferencesService.userType;
      if (!allowedUserTypes!.contains(userType)) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Access Denied'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.block,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have permission to access this page.\nRequired: ${allowedUserTypes!.join(', ')}\nYour type: $userType',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      }
    }

    // User is authenticated and authorized
    return child;
  }
}
