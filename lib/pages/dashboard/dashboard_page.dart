import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../../providers/task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/summary_card.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/upcoming_tasks.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToTasks;

  const DashboardPage({super.key, this.onNavigateToTasks});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Use auth name if logged in, otherwise use settings name
    final userName = authProvider.isLoggedIn 
        ? (authProvider.currentUser?.name ?? 'Pengguna')
        : settingsProvider.userName;

    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          onRefresh: () async {
            await taskProvider.loadTasks();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting!',
                        style: AppTextStyles.bodySmallOf(context),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: AppTextStyles.h1Of(context),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                    ],
                  ),
                ),
              ),

              // ── Summary Cards ───────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      SummaryCard(
                        icon: Icons.list_alt_rounded,
                        label: 'Total',
                        value: taskProvider.totalTasks.toString(),
                        gradient: AppColors.primaryGradient,
                        index: 0,
                      ),
                      SummaryCard(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Selesai',
                        value: taskProvider.completedTasks.toString(),
                        gradient: AppColors.successGradient,
                        index: 1,
                      ),
                      SummaryCard(
                        icon: Icons.pending_actions_rounded,
                        label: 'Tertunda',
                        value: taskProvider.pendingTasks.toString(),
                        gradient: AppColors.warningGradient,
                        index: 2,
                      ),
                      SummaryCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Terlambat',
                        value: taskProvider.overdueTasks.toString(),
                        gradient: AppColors.dangerGradient,
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Progress & Chart Row ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Productivity Ring
                      Expanded(
                        flex: 2,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text('Produktivitas',
                                  style: AppTextStyles.bodySmallOf(context)),
                              const SizedBox(height: 12),
                              ProgressRing(
                                progress: taskProvider.completionRate,
                                size: 90,
                                strokeWidth: 8,
                                gradient: AppColors.primaryGradient,
                                center: Text(
                                  '${(taskProvider.completionRate * 100).toInt()}%',
                                  style: AppTextStyles.h3Of(context).copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${taskProvider.thisWeekCompleted} selesai minggu ini',
                                style: AppTextStyles.captionOf(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 12),
                      // Weekly Chart
                      Expanded(
                        flex: 3,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('7 Hari Terakhir',
                                  style: AppTextStyles.bodySmallOf(context)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: WeeklyChart(
                                  data: taskProvider.weeklyCompletionData,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Upcoming Tasks ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tugas Mendatang',
                          style: AppTextStyles.h3Of(context)),
                      TextButton(
                        onPressed: onNavigateToTasks,
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms),
                ),
              ),

              SliverToBoxAdapter(
                child: UpcomingTasks(
                  tasks: taskProvider.upcomingTasks.take(5).toList(),
                  onToggle: (id) => taskProvider.toggleTask(id),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}
