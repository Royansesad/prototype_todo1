import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/task_model.dart';

class UpcomingTasks extends StatelessWidget {
  final List<TaskModel> tasks;
  final ValueChanged<String> onToggle;

  const UpcomingTasks({
    super.key,
    required this.tasks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: GlassCard(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.celebration_rounded,
                      size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada tugas mendatang',
                    style: AppTextStyles.bodySmallOf(context),
                  ),
                  Text(
                    'Kerja bagus! 🎉',
                    style: AppTextStyles.captionOf(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: tasks.map((task) {
          final priorityColor = _priorityColor(task.priority);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => onToggle(task.id),
              child: Row(
                children: [
                  // Priority dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & due date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: AppTextStyles.bodyOf(context).copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatDueDate(task.dueDate!),
                            style: AppTextStyles.captionOf(context).copyWith(
                              color: task.isOverdue
                                  ? AppColors.danger
                                  : AppColors.textTertiaryOf(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Checkbox
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggle(task.id),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color: AppColors.textTertiaryOf(context),
                      width: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 2:
        return AppColors.priorityHigh;
      case 1:
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    final diff = dueDay.difference(today).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    if (diff < 0) return 'Terlambat ${-diff} hari';
    if (diff <= 7) return '$diff hari lagi';
    try {
      return DateFormat('d MMM yyyy', 'id').format(date);
    } catch (_) {
      return DateFormat('d MMM yyyy').format(date);
    }
  }
}
