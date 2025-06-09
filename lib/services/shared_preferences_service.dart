import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false; // Add this flag

  static Future<void> init() async {
    if (!_isInitialized) {
      try {
        _prefs = await SharedPreferences.getInstance();
        _isInitialized = true;
        print('SharedPreferences initialized successfully');
      } catch (e) {
        print('Error initializing SharedPreferences: $e');
        _isInitialized = false;
      }
    }
  }

  // Add this getter
  static bool get isInitialized => _isInitialized;

  // Simple getters
  static bool get isLoggedIn => _prefs?.getBool('isLoggedIn') ?? false;
  static String get userType => _prefs?.getString('userType') ?? '';
  static String get userId => _prefs?.getString('userId') ?? '';
  static String get userEmail => _prefs?.getString('userEmail') ?? '';
  static String get userName => _prefs?.getString('userName') ?? '';
  static String get studentId => _prefs?.getString('studentId') ?? '';

  // Save login data
  static Future<void> setLoginState({
    required bool isLoggedIn,
    required String userType,
    required String userId,
    required String userEmail,
    String userName = '',
    String studentId = '',
  }) async {
    if (!_isInitialized) {
      await init();
    }

    await _prefs?.setBool('isLoggedIn', isLoggedIn);
    await _prefs?.setString('userType', userType);
    await _prefs?.setString('userId', userId);
    await _prefs?.setString('userEmail', userEmail);
    await _prefs?.setString('userName', userName);
    await _prefs?.setString('studentId', studentId);
  }

  // Alternative method name (for compatibility)
  static Future<void> saveLoginData({
    required String userType,
    required String userId,
    required String userEmail,
    String userName = '',
    String studentId = '',
  }) async {
    await setLoginState(
      isLoggedIn: true,
      userType: userType,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      studentId: studentId,
    );
  }

  // Clear all data
  static Future<void> clearAll() async {
    if (!_isInitialized) {
      await init();
    }
    await _prefs?.clear();
  }

  // Clear user data (alternative method)
  static Future<void> clearUserData() async {
    await clearAll();
  }
}
