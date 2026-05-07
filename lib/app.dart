import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/auth_wrapper.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'providers/task_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';

class TodoApp extends StatelessWidget {
  final StorageService storageService;
  final AuthService authService;

  const TodoApp({
    super.key,
    required this.storageService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(storageService)..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlanProvider(storageService)..loadPlans(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService)..loadSettings(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Todo App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
