import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = 'userId';
  // static const String _tokenKey = 'token';

  static Future<void> saveUserData(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    // await prefs.remove(_tokenKey);
  }

  static Future<void> clearUserData() async {
    await logout(); // Agora clearUserData chama logout
  }
}