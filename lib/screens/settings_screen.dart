import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../services/auth_state.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailUpdates = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('pref_notifications') ?? true;
      _emailUpdates = prefs.getBool('pref_email_updates') ?? false;
      _darkMode = prefs.getBool('pref_dark_mode') ?? false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleSignOut() async {
    // Centralized in AuthState.logout() rather than flipping the
    // ValueNotifier and SharedPreferences flag directly here.
    await AuthState.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const ScreenHeader(eyebrow: 'YOUR ACCOUNT', title: 'Settings'),
            const SizedBox(height: AppSpacing.xl),

            Text('Notifications', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            _switchTile(
              icon: Icons.notifications_outlined,
              title: 'Push notifications',
              subtitle: 'Get notified about new announcements',
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _setPref('pref_notifications', v);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _switchTile(
              icon: Icons.email_outlined,
              title: 'Email updates',
              subtitle: 'Receive a weekly summary by email',
              value: _emailUpdates,
              onChanged: (v) {
                setState(() => _emailUpdates = v);
                _setPref('pref_email_updates', v);
              },
            ),

            const SizedBox(height: AppSpacing.lg),
            Text('Appearance', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            _switchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark mode',
              subtitle: 'Coming soon',
              value: _darkMode,
              onChanged: null,
            ),

            const SizedBox(height: AppSpacing.lg),
            Text('About', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            _infoTile(Icons.info_outline, 'App version', '1.1.0'),
            const SizedBox(height: AppSpacing.sm),
            _infoTile(Icons.school_outlined, 'Portal', 'Student Portal'),

            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coral,
                  side: const BorderSide(color: AppColors.coral),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: onChanged == null ? AppColors.textMuted : AppColors.violet),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onChanged == null ? AppColors.textMuted : AppColors.textPrimary,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.violet,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.violet),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}