import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  File? _profileImageFile;
  File? get profileImageFile => _profileImageFile;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    await loadUserData();
    await loadProfilePicture();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    _user = await _authService.getCurrentUserDetails();
    notifyListeners();
  }

  Future<void> loadProfilePicture() async {
    final path = await _authService.getProfilePicturePath();
    if (path != null && path.isNotEmpty) {
      if (await File(path).exists()) {
        _profileImageFile = File(path);
      } else {
        await _authService.saveProfilePicturePath('');
        _profileImageFile = null;
      }
    } else {
      _profileImageFile = null;
    }
    notifyListeners();
  }

  Future<void> updateUsername(String username) async {
    if (username.trim().isEmpty) return;
    bool success = await _authService.updateUsername(username.trim());
    if (success) {
      await loadUserData();
    }
  }

  Future<void> saveProfilePicturePath(String path) async {
    await _authService.saveProfilePicturePath(path);
    await loadProfilePicture();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}