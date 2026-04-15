import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get isLoggedIn => _currentUser != null;

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }

  // Sign up
  Future<bool> signup({
    required String username,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      // Validate inputs
      if (username.isEmpty) {
        _errorMessage = 'Username cannot be empty';
        _setLoading(false);
        return false;
      }

      if (!_authService.isValidPhoneNumber(phone)) {
        _errorMessage = 'Please enter a valid 10-digit phone number';
        _setLoading(false);
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        _setLoading(false);
        return false;
      }

      final user = await _authService.signup(
        username: username,
        phone: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      }

      _errorMessage = 'Signup failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      if (!_authService.isValidPhoneNumber(phone)) {
        _errorMessage = 'Please enter a valid 10-digit phone number';
        _setLoading(false);
        return false;
      }

      if (password.isEmpty) {
        _errorMessage = 'Password cannot be empty';
        _setLoading(false);
        return false;
      }

      final user = await _authService.login(
        phone: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      }

      _errorMessage = 'Login failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _errorMessage = '';
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Check current user
  Future<void> checkCurrentUser() async {
    try {
      if (_authService.isUserLoggedIn()) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
