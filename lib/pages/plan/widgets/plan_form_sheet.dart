import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/plan_model.dart';
import '../../../providers/plan_provider.dart';

class PlanFormSheet extends StatefulWidget {
  final String? planId;

  const PlanFormSheet({super.key, this.planId});

  @override
  State<PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<PlanFormSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subTaskController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _colorHex = 'FF6C63FF';
  List<SubTask> _subTasks = [];
  bool _isEditing = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.planId != null) {
      _isEditing = true;
      final plan = context.read<PlanProvider>().getPlanById(widget.planId!);
      if (plan != null) {
        _titleController.text = plan.title;
        _descController.text = plan.description;
        _startDate = plan.startDate;
        _endDate = plan.endDate;
        _colorHex = plan.colorHex;
        _subTasks = plan.subTasks.map((s) => s.copyWith()).toList();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final provider = context.read<PlanProvider>();

    if (_isEditing) {
      final existing = provider.getPlanById(widget.planId!)!;
      provider.updatePlan(existing.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        colorHex: _colorHex,
        subTasks: _subTasks,
      ));
    } else {
      provider.addPlan(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        colorHex: _colorHex,
        subTasks: _subTasks,
      );
    }
    Navigator.pop(context);
  }

  void _addSubTask() {
    final title = _subTaskController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _subTasks.add(SubTask(
        id: _uuid.v4(),
        title: title,
        order: _subTasks.length,
      ));
      _subTaskController.clear();
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('d MMM yy', 'id').format(date);
    } catch (_) {
      return DateFormat('d MMM yy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              _isEditing ? 'Edit Rencana' : 'Rencana Baru',
              style: AppTextStyles.h3Of(context),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyOf(context),
              decoration: const InputDecoration(
                hintText: 'Judul rencana',
                prefixIcon: Icon(Icons.flag_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              style: AppTextStyles.bodyOf(context),
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Deskripsi (opsional)',
                prefixIcon: Icon(Icons.notes_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(true),
                    child: _dateChip(
                      context: context,
                      label: _startDate != null
                          ? _formatDate(_startDate!)
                          : 'Mulai',
                      icon: Icons.play_arrow_rounded,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward,
                      size: 16, color: AppColors.textTertiaryOf(context)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(false),
                    child: _dateChip(
                      context: context,
                      label: _endDate != null
                          ? _formatDate(_endDate!)
                          : 'Selesai',
                      icon: Icons.stop_rounded,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color picker
            Text('Warna', style: AppTextStyles.bodySmallOf(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: AppColors.planColors.asMap().entries.map((entry) {
                final c = entry.value;
                // Convert Color to hex string (AARRGGBB format)
                final a = (c.a * 255).round().toRadixString(16).padLeft(2, '0');
                final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
                final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
                final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
                final hex = '$a$r$g$b'.toUpperCase();
                final isSelected = _colorHex == hex;
                return GestureDetector(
                  onTap: () => setState(() => _colorHex = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Subtasks
            Text('Sub-tugas', style: AppTextStyles.bodySmallOf(context)),
            const SizedBox(height: 8),
            ..._subTasks.asMap().entries.map((entry) {
              final st = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator,
                        size: 16, color: AppColors.textTertiaryOf(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(st.title, style: AppTextStyles.bodyOf(context)),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _subTasks.removeAt(entry.key);
                        });
                      },
                      child: Icon(Icons.close,
                          size: 16, color: AppColors.textTertiaryOf(context)),
                    ),
                  ],
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subTaskController,
                    style: AppTextStyles.bodyOf(context),
                    decoration: const InputDecoration(
                      hintText: 'Tambah sub-tugas',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onSubmitted: (_) => _addSubTask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.primary),
                  onPressed: _addSubTask,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Buat Rencana'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateChip({required BuildContext context, required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderOf(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondaryOf(context)),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.bodySmallOf(context)
                  .copyWith(color: AppColors.textSecondaryOf(context))),
        ],
      ),
    );
  }
}
