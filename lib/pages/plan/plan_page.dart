import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/plan_provider.dart';
import 'widgets/plan_card.dart';
import 'widgets/plan_form_sheet.dart';
import 'widgets/plan_detail_sheet.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  void _showAddPlan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlanFormSheet(),
    );
  }

  void _showPlanDetail(BuildContext context, String planId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanDetailSheet(planId: planId),
    );
  }

  void _showEditPlan(BuildContext context, String planId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanFormSheet(planId: planId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final plans = planProvider.plans;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlan(context),
        child: const Icon(Icons.add_rounded, size: 28),
      )
          .animate()
          .fadeIn(delay: 300.ms)
          .scale(begin: const Offset(0.5, 0.5)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Rencana Saya', style: AppTextStyles.h2Of(context))
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '${planProvider.activePlans} aktif · ${planProvider.completedPlans} selesai',
                style: AppTextStyles.bodySmallOf(context),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            ),

            // ── Plans Grid ────────────────────────────────────
            Expanded(
              child: plans.isEmpty
                  ? EmptyState(
                      icon: Icons.calendar_month_rounded,
                      title: 'Belum ada rencana',
                      subtitle:
                          'Buat rencana pertamamu untuk\nmengorganisir tugas-tugasmu!',
                      buttonText: 'Buat Rencana',
                      onAction: () => _showAddPlan(context),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return PlanCard(
                          plan: plan,
                          index: index,
                          onTap: () => _showPlanDetail(context, plan.id),
                          onEdit: () => _showEditPlan(context, plan.id),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Rencana?'),
                                content: Text(
                                  'Rencana "${plan.title}" akan dihapus secara permanen.',
                                  style: AppTextStyles.bodyOf(context),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Hapus',
                                        style: TextStyle(
                                            color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              planProvider.deletePlan(plan.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
