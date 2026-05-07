import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  late SharedPreferences _prefs;
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'users';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if user is logged in
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  // Get current user
  UserModel? getCurrentUser() {
    final raw = _prefs.getString(_currentUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final users = await _getAllUsers();
      if (users.any((u) => u['email'] == email)) {
        return false; // Email already registered
      }

      // Create new user
      final user = UserModel(
        id: const Uuid().v4(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Save user credentials
      users.add({
        'email': email,
        'password': password,
        'user': user.toJson(),
      });
      await _prefs.setString(_usersKey, jsonEncode(users));

      // Set as current user
      await _prefs.setString(_currentUserKey, user.toJsonString());
      await _prefs.setBool(_isLoggedInKey, true);

      return true;
    } catch (_) {
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final users = await _getAllUsers();
      final userCredential = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (userCredential.isEmpty) {
        return false; // Invalid credentials
      }

      final user = UserModel.fromJson(userCredential['user'] as Map<String, dynamic>);
      await _prefs.setString(_currentUserKey, user.toJsonString());
      await _prefs.setBool(_isLoggedInKey, true);

      return true;
    } catch (_) {
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _prefs.remove(_currentUserKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }

  // Update user profile
  Future<bool> updateUser(UserModel user) async {
    try {
      await _prefs.setString(_currentUserKey, user.toJsonString());
      
      // Update in users list
      final users = await _getAllUsers();
      final index = users.indexWhere((u) => u['user']['id'] == user.id);
      if (index != -1) {
        users[index]['user'] = user.toJson();
        await _prefs.setString(_usersKey, jsonEncode(users));
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }

  // Get all users (for internal use)
  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }
}
