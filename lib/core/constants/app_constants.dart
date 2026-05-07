class AppConstants {
  AppConstants._();

  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusFull = 100.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Storage Keys
  static const String tasksKey = 'tasks_data';
  static const String plansKey = 'plans_data';
  static const String settingsKey = 'settings_data';

  // Priority Labels
  static const List<String> priorityLabels = ['Rendah', 'Sedang', 'Tinggi'];
}
