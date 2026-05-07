import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/plan_model.dart';
import '../models/app_settings_model.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Tasks ──────────────────────────────────────────────

  Future<List<TaskModel>> loadTasks() async {
    final raw = _prefs.getString(AppConstants.tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final json = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(AppConstants.tasksKey, json);
  }

  // ── Plans ──────────────────────────────────────────────

  Future<List<PlanModel>> loadPlans() async {
    final raw = _prefs.getString(AppConstants.plansKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlans(List<PlanModel> plans) async {
    final json = jsonEncode(plans.map((p) => p.toJson()).toList());
    await _prefs.setString(AppConstants.plansKey, json);
  }

  // ── Settings ───────────────────────────────────────────

  Future<AppSettingsModel> loadSettings() async {
    final raw = _prefs.getString(AppConstants.settingsKey);
    if (raw == null || raw.isEmpty) return AppSettingsModel();
    try {
      return AppSettingsModel.fromJsonString(raw);
    } catch (_) {
      return AppSettingsModel();
    }
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    await _prefs.setString(AppConstants.settingsKey, settings.toJsonString());
  }

  // ── Data Management ────────────────────────────────────

  Future<String> exportAllData() async {
    final tasks = await loadTasks();
    final plans = await loadPlans();
    final settings = await loadSettings();
    final data = {
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'plans': plans.map((p) => p.toJson()).toList(),
      'settings': settings.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importAllData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('tasks')) {
        final tasks = (data['tasks'] as List<dynamic>)
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await saveTasks(tasks);
      }

      if (data.containsKey('plans')) {
        final plans = (data['plans'] as List<dynamic>)
            .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await savePlans(plans);
      }

      if (data.containsKey('settings')) {
        final settings = AppSettingsModel.fromJson(
            data['settings'] as Map<String, dynamic>);
        await saveSettings(settings);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAllData() async {
    await _prefs.remove(AppConstants.tasksKey);
    await _prefs.remove(AppConstants.plansKey);
    await _prefs.remove(AppConstants.settingsKey);
  }
}
