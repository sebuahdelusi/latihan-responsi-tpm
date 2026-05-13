import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyPrefix = 'user_';
  static const String _keyLoggedIn = 'logged_in_user';

  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$username';

    if (prefs.containsKey(key)) {
      return false;
    }

    await prefs.setString(key, password);
    return true;
  }

  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$username';

    final storedPassword = prefs.getString(key);
    if (storedPassword == null) return false;

    if (storedPassword == password) {
      await prefs.setString(_keyLoggedIn, username);
      return true;
    }
    return false;
  }

  static Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedIn);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
  }
}
