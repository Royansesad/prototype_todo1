import 'dart:convert';

class SubTask {
  final String id;
  String title;
  bool isCompleted;
  int order;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.order = 0,
  });

  SubTask copyWith({
    String? title,
    bool? isCompleted,
    int? order,
  }) {
    return SubTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'order': order,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        order: json['order'] as int? ?? 0,
      );
}

class PlanModel {
  final String id;
  String title;
  String description;
  DateTime? startDate;
  DateTime? endDate;
  List<SubTask> subTasks;
  String colorHex;
  final DateTime createdAt;

  PlanModel({
    required this.id,
    required this.title,
    this.description = '',
    this.startDate,
    this.endDate,
    List<SubTask>? subTasks,
    this.colorHex = 'FF6C63FF',
    required this.createdAt,
  }) : subTasks = subTasks ?? [];

  PlanModel copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    List<SubTask>? subTasks,
    String? colorHex,
  }) {
    return PlanModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      subTasks: subTasks ?? this.subTasks.map((s) => s.copyWith()).toList(),
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
    );
  }

  double get progress {
    if (subTasks.isEmpty) return 0.0;
    final completed = subTasks.where((s) => s.isCompleted).length;
    return completed / subTasks.length;
  }

  int get completedCount => subTasks.where((s) => s.isCompleted).length;
  int get totalCount => subTasks.length;

  bool get isCompleted => subTasks.isNotEmpty && completedCount == totalCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'subTasks': subTasks.map((s) => s.toJson()).toList(),
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : null,
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        subTasks: (json['subTasks'] as List<dynamic>?)
                ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        colorHex: json['colorHex'] as String? ?? 'FF6C63FF',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory PlanModel.fromJsonString(String source) =>
      PlanModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
