import 'dart:convert';

class TaskModel {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  int priority; // 0=rendah, 1=sedang, 2=tinggi
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;
  String? planId;
  List<String> tags;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = 0,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.planId,
    List<String>? tags,
  }) : tags = tags ?? [];

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    int? priority,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? planId,
    bool clearPlanId = false,
    List<String>? tags,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      planId: clearPlanId ? null : (planId ?? this.planId),
      tags: tags ?? List.from(this.tags),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'planId': planId,
      'tags': tags,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: json['priority'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      planId: json['planId'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory TaskModel.fromJsonString(String source) =>
      TaskModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  bool get isOverdue =>
      !isCompleted &&
      dueDate != null &&
      dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return dueDate!.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dueDate!.isBefore(endOfWeek);
  }

  String get priorityLabel {
    switch (priority) {
      case 2:
        return 'Tinggi';
      case 1:
        return 'Sedang';
      default:
        return 'Rendah';
    }
  }
}
