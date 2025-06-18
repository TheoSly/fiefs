import 'package:feffs/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  User? currentUser;

  Future<void> loadCurrentUser() async {
    currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final session = await _authRepository.login(email, password);
    if (session != null) {
      await loadCurrentUser();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name, String text) async {
    final user = await _authRepository.register(email, password, name, text);
    if (user != null) {
      await loadCurrentUser();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    currentUser = null;
    notifyListeners();
  }
}
