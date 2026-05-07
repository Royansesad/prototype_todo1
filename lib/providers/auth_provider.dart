import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _loadCurrentUser();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load current user
  void _loadCurrentUser() {
    _currentUser = _authService.getCurrentUser();
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    if (success) {
      _currentUser = _authService.getCurrentUser();
      _errorMessage = null;
    } else {
      _errorMessage = 'Email sudah terdaftar';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.login(
      email: email,
      password: password,
    );

    if (success) {
      _currentUser = _authService.getCurrentUser();
      _errorMessage = null;
    } else {
      _errorMessage = 'Email atau password salah';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.updateUser(user);

    if (success) {
      _currentUser = user;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
