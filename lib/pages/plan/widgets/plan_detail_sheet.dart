import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../providers/plan_provider.dart';

class PlanDetailSheet extends StatefulWidget {
  final String planId;

  const PlanDetailSheet({super.key, required this.planId});

  @override
  State<PlanDetailSheet> createState() => _PlanDetailSheetState();
}

class _PlanDetailSheetState extends State<PlanDetailSheet> {
  final _newSubTaskController = TextEditingController();

  @override
  void dispose() {
    _newSubTaskController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('d MMM yyyy', 'id').format(date);
    } catch (_) {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanProvider>();
    final plan = provider.getPlanById(widget.planId);

    if (plan == null) {
      return const SizedBox();
    }

    final color = Color(int.parse(plan.colorHex, radix: 16));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiaryOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Color bar
          Container(
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            color: color,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.title, style: AppTextStyles.h2Of(context))
                                .animate()
                                .fadeIn(duration: 300.ms),
                            if (plan.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(plan.description,
                                    style: AppTextStyles.bodySmallOf(context)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ProgressRing(
                        progress: plan.progress,
                        size: 60,
                        strokeWidth: 6,
                        progressColor: color,
                        backgroundColor: AppColors.surfaceLightOf(context),
                        center: Text(
                          '${(plan.progress * 100).toInt()}%',
                          style: AppTextStyles.bodySmallOf(context).copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
                  ),

                  // Date range
                  if (plan.startDate != null || plan.endDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLightOf(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.date_range_rounded,
                              size: 18, color: AppColors.textSecondaryOf(context)),
                          const SizedBox(width: 8),
                          Text(
                            [
                              if (plan.startDate != null)
                                _formatDate(plan.startDate!),
                              if (plan.endDate != null)
                                _formatDate(plan.endDate!),
                            ].join(' → '),
                            style: AppTextStyles.bodySmallOf(context),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Subtasks header
                  Row(
                    children: [
                      Text('Sub-tugas', style: AppTextStyles.h3Of(context)),
                      const Spacer(),
                      Text(
                        '${plan.completedCount}/${plan.totalCount}',
                        style: AppTextStyles.bodySmallOf(context).copyWith(color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Subtask list
                  if (plan.subTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Belum ada sub-tugas',
                          style: AppTextStyles.bodySmallOf(context),
                        ),
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: plan.subTasks.length,
                      onReorder: (oldIndex, newIndex) {
                        provider.reorderSubTasks(
                            plan.id, oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final st = plan.subTasks[index];
                        return Padding(
                          key: Key(st.id),
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLightOf(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: GestureDetector(
                                onTap: () => provider.toggleSubTask(
                                    plan.id, st.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: st.isCompleted
                                        ? color
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: st.isCompleted
                                          ? color
                                          : AppColors.textTertiaryOf(context),
                                      width: 2,
                                    ),
                                  ),
                                  child: st.isCompleted
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ),
                              title: Text(
                                st.title,
                                style: AppTextStyles.bodyOf(context).copyWith(
                                  decoration: st.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: st.isCompleted
                                      ? AppColors.textTertiaryOf(context)
                                      : AppColors.textPrimaryOf(context),
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () => provider.deleteSubTask(
                                    plan.id, st.id),
                                child: Icon(Icons.close,
                                    size: 16, color: AppColors.textTertiaryOf(context)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Add subtask inline
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newSubTaskController,
                          style: AppTextStyles.bodyOf(context),
                          decoration: InputDecoration(
                            hintText: 'Tambah sub-tugas baru...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.glassBorderOf(context)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          onSubmitted: (_) {
                            final text = _newSubTaskController.text.trim();
                            if (text.isNotEmpty) {
                              provider.addSubTask(plan.id, text);
                              _newSubTaskController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final text = _newSubTaskController.text.trim();
                          if (text.isNotEmpty) {
                            provider.addSubTask(plan.id, text);
                            _newSubTaskController.clear();
                          }
                        },
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.primary, size: 32),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
