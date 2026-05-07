import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'app.dart';

void main() async {
  // Catch all unhandled errors to prevent force close
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('Flutter error: ${details.exception}');
      }
    };

    // Initialize Indonesian locale for date formatting
    await initializeDateFormatting('id');

    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1F36),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Initialize storage
    final storageService = StorageService();
    await storageService.init();

    // Initialize auth service
    final authService = AuthService();
    await authService.init();

    runApp(TodoApp(
      storageService: storageService,
      authService: authService,
    ));
  }, (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Unhandled error: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  });
}
