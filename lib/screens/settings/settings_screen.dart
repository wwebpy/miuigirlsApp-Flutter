import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../providers/app_provider.dart';
import '../../services/language_service.dart';
import '../../models/app_theme_model.dart';
import 'theme_selection_screen.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyMotivationReminder = true;
  bool _moodTrackingReminder = true;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep shining ✨',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications', colors),
          const SizedBox(height: 12),
          _buildSettingCard(
            colors,
            child: Column(
              children: [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive notifications from the app',
                  Icons.notifications_rounded,
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                  colors,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  'Daily Motivation',
                  'Get your daily dose of inspiration',
                  Icons.auto_awesome_rounded,
                  _dailyMotivationReminder,
                  (value) => setState(() => _dailyMotivationReminder = value),
                  colors,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  'Mood Tracking Reminder',
                  'Remember to track your daily mood',
                  Icons.sentiment_satisfied_alt_rounded,
                  _moodTrackingReminder,
                  (value) => setState(() => _moodTrackingReminder = value),
                  colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Settings Section
          _buildSectionHeader('App Settings', colors),
          const SizedBox(height: 12),
          _buildSettingCard(
            colors,
            child: Column(
              children: [
                _buildNavigationTile(
                  'Language',
                  LanguageService.languageNames[appProvider.currentLanguage] ?? 'English',
                  Icons.language_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSelectionScreen(),
                      ),
                    );
                  },
                  colors,
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  'Theme',
                  AppThemes.themeNames[appProvider.currentThemeId] ?? 'Soft Rose',
                  Icons.palette_rounded,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemeSelectionScreen(),
                      ),
                    );
                  },
                  colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy & Security Section
          _buildSectionHeader('Privacy & Security', colors),
          const SizedBox(height: 12),
          _buildSettingCard(
            colors,
            child: Column(
              children: [
                _buildNavigationTile(
                  'Privacy Policy',
                  '',
                  Icons.privacy_tip_rounded,
                  () {},
                  colors,
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  'Terms of Service',
                  '',
                  Icons.description_rounded,
                  () {},
                  colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data', colors),
          const SizedBox(height: 12),
          _buildSettingCard(
            colors,
            child: Column(
              children: [
                _buildNavigationTile(
                  'Export Data',
                  '',
                  Icons.file_download_rounded,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                  colors,
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  'Clear All Data',
                  '',
                  Icons.delete_outline_rounded,
                  () => _showClearDataDialog(colors),
                  colors,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', colors),
          const SizedBox(height: 12),
          _buildSettingCard(
            colors,
            child: Column(
              children: [
                _buildNavigationTile(
                  'Help & Support',
                  '',
                  Icons.help_outline_rounded,
                  () {},
                  colors,
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  'Rate App',
                  '',
                  Icons.star_outline_rounded,
                  () {},
                  colors,
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  'About Miui',
                  'Version 1.0.0',
                  Icons.info_outline_rounded,
                  () => _showAboutDialog(colors),
                  colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeColors colors) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
    );
  }

  Widget _buildSettingCard(ThemeColors colors, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String trailing,
    IconData icon,
    VoidCallback onTap,
    ThemeColors colors, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? colors.error.withOpacity(0.15)
                    : colors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? colors.error : colors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? colors.error : colors.textPrimary,
                    ),
              ),
            ),
            if (trailing.isNotEmpty)
              Text(
                trailing,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(ThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your goals, notes, moods, and reminders. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: Text(
              'Clear',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(ThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('About Miui'),
          ],
        ),
        content: const Text(
          'Miui is your daily motivation companion, helping you stay inspired, track your goals, and build positive habits.\n\nVersion 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
