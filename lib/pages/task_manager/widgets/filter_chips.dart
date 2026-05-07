import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/task_provider.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final current = provider.currentFilter;

    final filters = [
      _FilterItem(TaskFilter.all, 'Semua', Icons.list_rounded),
      _FilterItem(TaskFilter.today, 'Hari Ini', Icons.today_rounded),
      _FilterItem(TaskFilter.upcoming, 'Mendatang', Icons.upcoming_rounded),
      _FilterItem(TaskFilter.completed, 'Selesai', Icons.done_all_rounded),
      _FilterItem(
          TaskFilter.highPriority, 'Prioritas', Icons.priority_high_rounded),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = current == f.filter;

          return GestureDetector(
            onTap: () => provider.setFilter(f.filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceLightOf(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.glassBorderOf(context),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f.icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiaryOf(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f.label,
                    style: AppTextStyles.bodySmallOf(context).copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondaryOf(context),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterItem {
  final TaskFilter filter;
  final String label;
  final IconData icon;
  const _FilterItem(this.filter, this.label, this.icon);
}
