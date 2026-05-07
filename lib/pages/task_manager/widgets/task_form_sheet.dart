import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/plan_provider.dart';


class TaskFormSheet extends StatefulWidget {
  final String? taskId; // null = new task

  const TaskFormSheet({super.key, this.taskId});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 0;
  String? _planId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _isEditing = true;
      final task = context.read<TaskProvider>().allTasks.firstWhere(
            (t) => t.id == widget.taskId,
          );
      _titleController.text = task.title;
      _descController.text = task.description;
      _dueDate = task.dueDate;
      _priority = task.priority;
      _planId = task.planId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final taskProvider = context.read<TaskProvider>();

    if (_isEditing) {
      final existing = taskProvider.allTasks.firstWhere(
        (t) => t.id == widget.taskId,
      );
      taskProvider.updateTask(existing.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        priority: _priority,
        planId: _planId,
        clearPlanId: _planId == null,
      ));
    } else {
      taskProvider.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        planId: _planId,
      );
    }

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: DateTime(now.year + 5, now.month, now.day),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surface,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id').format(date);
    } catch (_) {
      // Fallback if 'id' locale is not available
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.read<PlanProvider>().plans;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _isEditing ? 'Edit Tugas' : 'Tugas Baru',
              style: AppTextStyles.h3Of(context),
            ),
            const SizedBox(height: 16),

            // Title field
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyOf(context),
              decoration: const InputDecoration(
                hintText: 'Judul tugas',
                prefixIcon: Icon(Icons.title_rounded, size: 20),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Description field
            TextField(
              controller: _descController,
              style: AppTextStyles.bodyOf(context),
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Deskripsi (opsional)',
                prefixIcon: Icon(Icons.notes_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // Due date
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorderOf(context)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 20, color: AppColors.textSecondaryOf(context)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? _formatDate(_dueDate!)
                            : 'Pilih tanggal jatuh tempo',
                        style: AppTextStyles.bodyOf(context).copyWith(
                          color: _dueDate != null
                              ? AppColors.textPrimaryOf(context)
                              : AppColors.textTertiaryOf(context),
                        ),
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(Icons.close,
                            size: 18,
                            color: AppColors.textTertiaryOf(context)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            Text('Prioritas', style: AppTextStyles.bodySmallOf(context)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(3, (i) {
                final colors = [
                  AppColors.priorityLow,
                  AppColors.priorityMedium,
                  AppColors.priorityHigh,
                ];
                final labels = ['Rendah', 'Sedang', 'Tinggi'];
                final isSelected = _priority == i;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors[i].withValues(alpha: 0.2)
                              : AppColors.surfaceLightOf(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? colors[i]
                                : AppColors.glassBorderOf(context),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: AppTextStyles.bodySmallOf(context).copyWith(
                              color: isSelected
                                  ? colors[i]
                                  : AppColors.textSecondaryOf(context),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Plan link
            if (plans.isNotEmpty) ...[
              Text('Tautkan ke Rencana',
                  style: AppTextStyles.bodySmallOf(context)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorderOf(context)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _planId,
                    isExpanded: true,
                    dropdownColor: isDark
                        ? AppColors.surface
                        : AppColors.lightSurface,
                    hint: Text('Pilih rencana (opsional)',
                        style: AppTextStyles.bodyOf(context).copyWith(
                            color: AppColors.textTertiaryOf(context))),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Tidak ada',
                            style: AppTextStyles.bodyOf(context)),
                      ),
                      ...plans.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.title,
                                style: AppTextStyles.bodyOf(context)),
                          )),
                    ],
                    onChanged: (v) => setState(() => _planId = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Tugas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
