import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';
import '../models/user_model.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _userProfilePicPathKey = 'userProfilePicPath';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register(String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception("Username, email dan password tidak boleh kosong.");
    }
    final existingUser = await _dbHelper.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception("Email sudah terdaftar.");
    }

    final hashedPassword = _hashPassword(password);
    final newUser = User(username: username, email: email, password: hashedPassword);
    
    final result = await _dbHelper.registerUser(newUser);
    return result != -1;
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email dan password tidak boleh kosong.");
    }

    final user = await _dbHelper.getUserByEmail(email);
    if (user == null) {
      throw Exception("Email tidak ditemukan.");
    }

    final hashedPassword = _hashPassword(password);
    if (user.password == hashedPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userEmailKey, email);
      return true;
    } else {
      throw Exception("Password salah.");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userProfilePicPathKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<User?> getCurrentUserDetails() async {
    final email = await getUserEmail();
    if (email != null) {
      return await _dbHelper.getUserByEmail(email);
    }
    return null;
  }

  Future<bool> updateUsername(String newUsername) async {
    final email = await getUserEmail();
    if (email == null) {
      throw Exception("User tidak login.");
    }
    if (newUsername.isEmpty) {
      throw Exception("Username baru tidak boleh kosong.");
    }
    final result = await _dbHelper.updateUsername(email, newUsername);
    return result > 0;
  }

  Future<void> saveProfilePicturePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfilePicPathKey, path);
  }

  Future<String?> getProfilePicturePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userProfilePicPathKey);
  }
}