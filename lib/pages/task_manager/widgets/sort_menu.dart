import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/task_provider.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return PopupMenuButton<TaskSort>(
      icon: Icon(Icons.sort_rounded,
          color: AppColors.textSecondaryOf(context)),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (sort) => provider.setSort(sort),
      itemBuilder: (_) => [
        _buildItem(context, TaskSort.dateNewest, 'Terbaru', provider.currentSort),
        _buildItem(context, TaskSort.dateOldest, 'Terlama', provider.currentSort),
        _buildItem(context,
            TaskSort.priorityHigh, 'Prioritas Tinggi', provider.currentSort),
        _buildItem(context,
            TaskSort.priorityLow, 'Prioritas Rendah', provider.currentSort),
        _buildItem(context, TaskSort.nameAZ, 'Nama A-Z', provider.currentSort),
        _buildItem(context, TaskSort.nameZA, 'Nama Z-A', provider.currentSort),
      ],
    );
  }

  PopupMenuItem<TaskSort> _buildItem(
      BuildContext context, TaskSort value, String label, TaskSort current) {
    final isSelected = current == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            const Icon(Icons.check, size: 16, color: AppColors.primary)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyOf(context).copyWith(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textPrimaryOf(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
