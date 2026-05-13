import 'package:shared_preferences/shared_preferences.dart';

/// Service autentikasi sederhana menggunakan SharedPreferences.
///
/// Menyimpan data user (username + password) secara lokal.
/// Tidak ada backend — murni lokal untuk keperluan praktikum.
class AuthService {
  static const String _keyPrefix = 'user_';
  static const String _keyLoggedIn = 'logged_in_user';

  /// Register user baru.
  /// Mengembalikan `true` jika berhasil, `false` jika username sudah ada.
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$username';

    // Cek apakah username sudah terdaftar
    if (prefs.containsKey(key)) {
      return false;
    }

    await prefs.setString(key, password);
    return true;
  }

  /// Login user.
  /// Mengembalikan `true` jika username dan password cocok.
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$username';

    final storedPassword = prefs.getString(key);
    if (storedPassword == null) return false;

    if (storedPassword == password) {
      // Simpan session
      await prefs.setString(_keyLoggedIn, username);
      return true;
    }
    return false;
  }

  /// Mendapatkan username yang sedang login.
  static Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedIn);
  }

  /// Logout — hapus session.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
  }
}
