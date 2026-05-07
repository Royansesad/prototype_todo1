import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/task_provider.dart';
import 'widgets/task_tile.dart';
import 'widgets/task_form_sheet.dart';
import 'widgets/filter_chips.dart';
import 'widgets/sort_menu.dart';

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TaskFormSheet(),
    );
  }

  void _showEditTask(String taskId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskFormSheet(taskId: taskId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.filteredTasks;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTask,
        child: const Icon(Icons.add_rounded, size: 28),
      )
          .animate()
          .fadeIn(delay: 300.ms)
          .scale(begin: const Offset(0.5, 0.5)),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  if (!_showSearch)
                    Expanded(
                      child: Text('Tugas Saya',
                              style: AppTextStyles.h2Of(context))
                          .animate()
                          .fadeIn(duration: 300.ms),
                    ),
                  if (_showSearch)
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: AppTextStyles.bodyOf(context),
                        decoration: InputDecoration(
                          hintText: 'Cari tugas...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.transparent,
                          filled: true,
                        ),
                        onChanged: (v) => taskProvider.setSearch(v),
                      ).animate().fadeIn(duration: 200.ms),
                    ),
                  IconButton(
                    icon: Icon(
                      _showSearch ? Icons.close : Icons.search_rounded,
                      color: AppColors.textSecondaryOf(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) {
                          _searchController.clear();
                          taskProvider.setSearch('');
                        }
                      });
                    },
                  ),
                  const SortMenu(),
                ],
              ),
            ),

            // ── Filter Chips ──────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: TaskFilterChips(),
            ),

            // ── Task List ─────────────────────────────────────
            Expanded(
              child: tasks.isEmpty
                  ? EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: taskProvider.currentFilter == TaskFilter.all
                          ? 'Belum ada tugas'
                          : 'Tidak ada tugas',
                      subtitle: taskProvider.currentFilter == TaskFilter.all
                          ? 'Mulai tambahkan tugas pertamamu!'
                          : 'Tidak ada tugas untuk filter ini',
                      buttonText: taskProvider.currentFilter == TaskFilter.all
                          ? 'Tambah Tugas'
                          : null,
                      onAction: taskProvider.currentFilter == TaskFilter.all
                          ? _showAddTask
                          : null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskTile(
                          task: task,
                          index: index,
                          onToggle: () => taskProvider.toggleTask(task.id),
                          onEdit: () => _showEditTask(task.id),
                          onDelete: () async {
                            final removed =
                                await taskProvider.deleteTask(task.id);
                            if (removed != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('"${removed.title}" dihapus'),
                                  action: SnackBarAction(
                                    label: 'BATAL',
                                    textColor: AppColors.primary,
                                    onPressed: () {
                                      taskProvider.restoreTask(removed);
                                    },
                                  ),
                                ),
                              );
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
