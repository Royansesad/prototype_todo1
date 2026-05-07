import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../profile/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          physics: const BouncingScrollPhysics(),
          children: [
            Text('Setelan', style: AppTextStyles.h2Of(context))
                .animate()
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 24),

            // ── Profile Section ───────────────────────────────
            GlassCard(
              onTap: isLoggedIn
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  : null,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      image: isLoggedIn &&
                              currentUser?.photoUrl != null &&
                              currentUser!.photoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(currentUser.photoUrl!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: isLoggedIn &&
                            (currentUser?.photoUrl == null ||
                                currentUser!.photoUrl!.isEmpty)
                        ? Center(
                            child: Text(
                              currentUser?.initials ?? 'U',
                              style: AppTextStyles.h2
                                  .copyWith(color: Colors.white),
                            ),
                          )
                        : !isLoggedIn
                            ? const Center(
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 28),
                              )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn
                              ? (currentUser?.name ?? 'Pengguna')
                              : 'Belum Login',
                          style: AppTextStyles.subtitleOf(context),
                        ),
                        Text(
                          isLoggedIn
                              ? (currentUser?.email ?? 'Pengguna Lokal')
                              : 'Silakan login terlebih dahulu',
                          style: AppTextStyles.captionOf(context),
                        ),
                      ],
                    ),
                  ),
                  if (isLoggedIn)
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondaryOf(context),
                      size: 20,
                    ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // ── Appearance ────────────────────────────────────
            _sectionTitle(context, 'Tampilan', Icons.palette_rounded, 200),
            const SizedBox(height: 8),
            _settingsTile(
              context: context,
              icon: Icons.dark_mode_rounded,
              title: 'Mode Gelap',
              subtitle: settings.isDarkMode ? 'Aktif' : 'Nonaktif',
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (_) {
                  settings.toggleDarkMode();
                  // Update system UI overlay to match theme
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: settings.isDarkMode
                        ? Brightness.dark
                        : Brightness.light,
                    systemNavigationBarColor: settings.isDarkMode
                        ? const Color(0xFFF5F6FA)
                        : const Color(0xFF1A1F36),
                    systemNavigationBarIconBrightness: settings.isDarkMode
                        ? Brightness.dark
                        : Brightness.light,
                  ));
                },
                activeColor: AppColors.primary,
              ),
              index: 1,
            ),

            const SizedBox(height: 20),

            // ── Notifications ─────────────────────────────────
            _sectionTitle(
                context, 'Notifikasi', Icons.notifications_rounded, 300),
            const SizedBox(height: 8),
            _settingsTile(
              context: context,
              icon: Icons.notifications_active_rounded,
              title: 'Pengingat',
              subtitle: settings.enableNotifications ? 'Aktif' : 'Nonaktif',
              trailing: Switch(
                value: settings.enableNotifications,
                onChanged: (_) => settings.toggleNotifications(),
                activeColor: AppColors.primary,
              ),
              index: 2,
            ),
            if (settings.enableNotifications)
              _settingsTile(
                context: context,
                icon: Icons.timer_rounded,
                title: 'Waktu Pengingat',
                subtitle: '${settings.reminderMinutes} menit sebelum',
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textTertiaryOf(context)),
                onTap: () => _showReminderPicker(context, settings),
                index: 3,
              ),

            const SizedBox(height: 20),

            // ── Account Management ───────────────────────────
            if (isLoggedIn) ...[
              _sectionTitle(context, 'Akun', Icons.account_circle_rounded, 350),
              const SizedBox(height: 8),
              _settingsTile(
                context: context,
                icon: Icons.logout_rounded,
                title: 'Keluar',
                subtitle: 'Logout dari akun',
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textTertiaryOf(context)),
                onTap: () => _handleLogout(context),
                index: 3,
                isDanger: true,
              ),
              const SizedBox(height: 20),
            ],

            // ── Data Management ──────────────────────────────
            _sectionTitle(context, 'Kelola Data', Icons.storage_rounded, 400),
            const SizedBox(height: 8),
            _settingsTile(
              context: context,
              icon: Icons.file_upload_outlined,
              title: 'Ekspor Data',
              subtitle: 'Simpan data sebagai JSON',
              trailing: Icon(Icons.chevron_right,
                  color: AppColors.textTertiaryOf(context)),
              onTap: () => _exportData(context),
              index: 4,
            ),
            _settingsTile(
              context: context,
              icon: Icons.delete_outline_rounded,
              title: 'Hapus Semua Data',
              subtitle: 'Hapus semua tugas, rencana, dan setelan',
              trailing:
                  const Icon(Icons.chevron_right, color: AppColors.danger),
              onTap: () => _clearAllData(context),
              index: 5,
              isDanger: true,
            ),

            const SizedBox(height: 20),

            // ── About ────────────────────────────────────────
            _sectionTitle(context, 'Tentang', Icons.info_outline_rounded, 500),
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          'assets/icon.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Study Planner',
                                style: AppTextStyles.subtitleOf(context)),
                            Text('Versi 0.6.7',
                                style: AppTextStyles.captionOf(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dibuat dengan AI untuk kuantitas',
                    style: AppTextStyles.bodySmallOf(context),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
      BuildContext context, String title, IconData icon, int delayMs) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title,
            style: AppTextStyles.subtitleOf(context)
                .copyWith(color: AppColors.primary)),
      ],
    ).animate().fadeIn(delay: delayMs.ms, duration: 300.ms);
  }

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required int index,
    bool isDanger = false,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDanger
                  ? AppColors.danger.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 20,
                color: isDanger ? AppColors.danger : AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyOf(context).copyWith(
                    color: isDanger
                        ? AppColors.danger
                        : AppColors.textPrimaryOf(context),
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle, style: AppTextStyles.captionOf(context)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (100 + index * 80).ms, duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  void _showReminderPicker(BuildContext context, SettingsProvider settings) {
    final options = [5, 10, 15, 30, 60];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Waktu Pengingat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((min) {
            final isSelected = settings.reminderMinutes == min;
            return ListTile(
              title: Text(
                '$min menit sebelum',
                style: TextStyle(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary, size: 20)
                  : null,
              onTap: () {
                settings.updateReminderMinutes(min);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final storage = context.read<StorageService>();
    final json = await storage.exportAllData();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Data Diekspor'),
          content: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: AppTextStyles.captionOf(context).copyWith(fontSize: 10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: json));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Data telah disalin ke clipboard')),
                );
              },
              child: const Text('Salin'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  void _clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Semua tugas, rencana, dan setelan akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final storage = context.read<StorageService>();
      await storage.clearAllData();
      if (context.mounted) {
        // Reload all providers to reflect cleared data
        context.read<TaskProvider>().loadTasks();
        context.read<PlanProvider>().loadPlans();
        context.read<SettingsProvider>().loadSettings();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data telah dihapus')),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil keluar')),
        );
      }
    }
  }
}
