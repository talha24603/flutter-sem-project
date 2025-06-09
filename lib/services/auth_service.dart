import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_preferences_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user (this was missing)
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is currently signed in
  bool get isSignedIn => _auth.currentUser != null && SharedPreferencesService.isLoggedIn;

  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email ?? SharedPreferencesService.userEmail;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid ?? SharedPreferencesService.userId;

  // Sign up
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        ...userData,
      });

      // Save to SharedPreferences
      await SharedPreferencesService.setLoginState(
        isLoggedIn: true,
        userType: userData['userType'] ?? 'student',
        userId: result.user!.uid,
        userEmail: email,
        userName: userData['name'] ?? '',
        studentId: userData['studentId'] ?? '',
      );

      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign in
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Determine user type
      String userType = 'student';
      String userName = '';
      String studentId = '';

      // Check if admin
      List<String> adminEmails = [
        'admin@comsats.edu.pk',
        'director@comsats.edu.pk',
        'it.admin@comsats.edu.pk',
      ];

      if (adminEmails.contains(email.toLowerCase())) {
        userType = 'admin';
        userName = 'Admin User';
      } else {
        // Get user data from Firestore
        try {
          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(result.user!.uid)
              .get();

          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            userType = data['userType'] ?? 'student';
            userName = data['name'] ?? data['fullName'] ?? '';
            studentId = data['studentId'] ?? '';
          }
        } catch (e) {
          print('Error getting user data: $e');
        }
      }

      // Save to SharedPreferences
      await SharedPreferencesService.setLoginState(
        isLoggedIn: true,
        userType: userType,
        userId: result.user!.uid,
        userEmail: email,
        userName: userName,
        studentId: studentId,
      );

      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await SharedPreferencesService.clearUserData();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
