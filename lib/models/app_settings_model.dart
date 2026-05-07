import 'dart:convert';

class AppSettingsModel {
  bool isDarkMode;
  bool enableNotifications;
  String userName;
  int reminderMinutes;

  AppSettingsModel({
    this.isDarkMode = true,
    this.enableNotifications = true,
    this.userName = 'Pengguna',
    this.reminderMinutes = 30,
  });

  AppSettingsModel copyWith({
    bool? isDarkMode,
    bool? enableNotifications,
    String? userName,
    int? reminderMinutes,
  }) {
    return AppSettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      userName: userName ?? this.userName,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'enableNotifications': enableNotifications,
        'userName': userName,
        'reminderMinutes': reminderMinutes,
      };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      AppSettingsModel(
        isDarkMode: json['isDarkMode'] as bool? ?? true,
        enableNotifications: json['enableNotifications'] as bool? ?? true,
        userName: json['userName'] as String? ?? 'Pengguna',
        reminderMinutes: json['reminderMinutes'] as int? ?? 30,
      );

  String toJsonString() => jsonEncode(toJson());

  factory AppSettingsModel.fromJsonString(String source) =>
      AppSettingsModel.fromJson(
          jsonDecode(source) as Map<String, dynamic>);
}
