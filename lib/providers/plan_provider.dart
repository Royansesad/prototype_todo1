import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/plan_model.dart';
import '../services/storage_service.dart';

class PlanProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  List<PlanModel> _plans = [];
  bool _isLoading = false;

  PlanProvider(this._storage);

  // ── Getters ─────────────────────────────────────────────

  List<PlanModel> get plans => List.unmodifiable(_plans);
  bool get isLoading => _isLoading;

  int get totalPlans => _plans.length;
  int get completedPlans => _plans.where((p) => p.isCompleted).length;
  int get activePlans => _plans.where((p) => !p.isCompleted).length;

  PlanModel? getPlanById(String id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Actions ─────────────────────────────────────────────

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();
    _plans = await _storage.loadPlans();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlan({
    required String title,
    String description = '',
    DateTime? startDate,
    DateTime? endDate,
    String colorHex = 'FF6C63FF',
    List<SubTask>? subTasks,
  }) async {
    final plan = PlanModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      colorHex: colorHex,
      subTasks: subTasks,
      createdAt: DateTime.now(),
    );
    _plans.add(plan);
    await _storage.savePlans(_plans);
    notifyListeners();
  }

  Future<void> updatePlan(PlanModel updated) async {
    final index = _plans.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _plans[index] = updated;
      await _storage.savePlans(_plans);
      notifyListeners();
    }
  }

  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
    await _storage.savePlans(_plans);
    notifyListeners();
  }

  // ── Subtask Actions ────────────────────────────────────

  Future<void> addSubTask(String planId, String title) async {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      final plan = _plans[index];
      final subTask = SubTask(
        id: _uuid.v4(),
        title: title,
        order: plan.subTasks.length,
      );
      plan.subTasks.add(subTask);
      await _storage.savePlans(_plans);
      notifyListeners();
    }
  }

  Future<void> toggleSubTask(String planId, String subTaskId) async {
    final planIndex = _plans.indexWhere((p) => p.id == planId);
    if (planIndex != -1) {
      final plan = _plans[planIndex];
      final stIndex = plan.subTasks.indexWhere((s) => s.id == subTaskId);
      if (stIndex != -1) {
        plan.subTasks[stIndex].isCompleted = !plan.subTasks[stIndex].isCompleted;
        await _storage.savePlans(_plans);
        notifyListeners();
      }
    }
  }

  Future<void> deleteSubTask(String planId, String subTaskId) async {
    final planIndex = _plans.indexWhere((p) => p.id == planId);
    if (planIndex != -1) {
      _plans[planIndex].subTasks.removeWhere((s) => s.id == subTaskId);
      await _storage.savePlans(_plans);
      notifyListeners();
    }
  }

  Future<void> reorderSubTasks(String planId, int oldIndex, int newIndex) async {
    final planIndex = _plans.indexWhere((p) => p.id == planId);
    if (planIndex != -1) {
      final subs = _plans[planIndex].subTasks;
      if (newIndex > oldIndex) newIndex--;
      final item = subs.removeAt(oldIndex);
      subs.insert(newIndex, item);
      for (var i = 0; i < subs.length; i++) {
        subs[i].order = i;
      }
      await _storage.savePlans(_plans);
      notifyListeners();
    }
  }
}
