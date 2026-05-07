import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../pages/auth/login_page.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/task_manager/task_manager_page.dart';
import '../../pages/plan/plan_page.dart';
import '../../pages/settings/settings_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoggedIn) {
          return const AppShell();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      DashboardPage(onNavigateToTasks: () => _goToPage(1)),
      const TaskManagerPage(),
      const PlanPage(),
      const SettingsPage(),
    ]);
  }

  void _goToPage(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _goToPage,
      ),
    );
  }
}
