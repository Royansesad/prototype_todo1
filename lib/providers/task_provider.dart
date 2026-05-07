import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';

enum TaskFilter { all, today, upcoming, completed, highPriority }

enum TaskSort { dateNewest, dateOldest, priorityHigh, priorityLow, nameAZ, nameZA }

class TaskProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.dateNewest;
  String _searchQuery = '';
  bool _isLoading = false;

  TaskProvider(this._storage);

  // ── Getters ─────────────────────────────────────────────

  List<TaskModel> get allTasks => List.unmodifiable(_tasks);
  TaskFilter get currentFilter => _currentFilter;
  TaskSort get currentSort => _currentSort;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<TaskModel> get filteredTasks {
    var list = List<TaskModel>.from(_tasks);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q)).toList();
    }

    // Apply filter
    switch (_currentFilter) {
      case TaskFilter.today:
        list = list.where((t) => t.isDueToday && !t.isCompleted).toList();
        break;
      case TaskFilter.upcoming:
        list = list.where((t) =>
            !t.isCompleted &&
            t.dueDate != null &&
            t.dueDate!.isAfter(DateTime.now())).toList();
        break;
      case TaskFilter.completed:
        list = list.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.highPriority:
        list = list.where((t) => t.priority == 2 && !t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Apply sort
    switch (_currentSort) {
      case TaskSort.dateNewest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSort.dateOldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case TaskSort.priorityHigh:
        list.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case TaskSort.priorityLow:
        list.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case TaskSort.nameAZ:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case TaskSort.nameZA:
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return list;
  }

  // ── Stats ───────────────────────────────────────────────

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;
  int get todayTasks => _tasks.where((t) => t.isDueToday && !t.isCompleted).length;

  double get completionRate =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  List<TaskModel> get upcomingTasks {
    return _tasks
        .where((t) => !t.isCompleted && t.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  /// Returns completed task count for last 7 days [Mon..Sun]
  List<int> get weeklyCompletionData {
    final now = DateTime.now();
    final result = List<int>.filled(7, 0);

    for (final task in _tasks) {
      if (task.isCompleted && task.completedAt != null) {
        final diff = now.difference(task.completedAt!).inDays;
        if (diff < 7 && diff >= 0) {
          final dayIndex = 6 - diff; // 0=oldest, 6=today
          result[dayIndex]++;
        }
      }
    }
    return result;
  }

  int get thisWeekCompleted {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return now.difference(t.completedAt!).inDays < 7;
    }).length;
  }

  // ── Actions ─────────────────────────────────────────────

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _storage.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    int priority = 0,
    String? planId,
    List<String>? tags,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      createdAt: DateTime.now(),
      planId: planId,
      tags: tags,
    );
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        clearCompletedAt: task.isCompleted,
      );
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<TaskModel?> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final removed = _tasks.removeAt(index);
      await _storage.saveTasks(_tasks);
      notifyListeners();
      return removed;
    }
    return null;
  }

  Future<void> restoreTask(TaskModel task) async {
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    _currentSort = sort;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
