import 'package:flutter/foundation.dart';
import '../models/app_settings_model.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  AppSettingsModel _settings = AppSettingsModel();
  bool _isLoading = false;

  SettingsProvider(this._storage);

  // ── Getters ─────────────────────────────────────────────

  AppSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _settings.isDarkMode;
  bool get enableNotifications => _settings.enableNotifications;
  String get userName => _settings.userName;
  int get reminderMinutes => _settings.reminderMinutes;

  // ── Actions ─────────────────────────────────────────────

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    _settings = await _storage.loadSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _settings =
        _settings.copyWith(enableNotifications: !_settings.enableNotifications);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _settings = _settings.copyWith(userName: name);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateReminderMinutes(int minutes) async {
    _settings = _settings.copyWith(reminderMinutes: minutes);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettingsModel settings) async {
    _settings = settings;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }
}
