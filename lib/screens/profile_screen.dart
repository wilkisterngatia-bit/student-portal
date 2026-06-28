import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_pill.dart';
import '../services/student_api.dart';
import '../services/course_registration_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _admissionNo = '';
  String _course = '';
  String? _photoUrl;

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPhoto = prefs.getString('profile_photo_url');

      final record = await StudentApi.fetchStudentRecord();
      final photoUrl = record['photo_url'];
      if (photoUrl != null) {
        await prefs.setString('profile_photo_url', photoUrl);
      }

      final registeredCourse = await CourseRegistrationStore.getCurrentCourse();

      setState(() {
        _name = record['name']!;
        _admissionNo = record['admission_no']!;
        _course = registeredCourse ?? record['course']!;
        _photoUrl = photoUrl ?? cachedPhoto;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not reach the school server. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(eyebrow: 'YOUR ACCOUNT', title: 'Profile'),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.violet));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(_errorMessage, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.violetSoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.violet.withOpacity(0.3)),
              ),
              clipBehavior: Clip.antiAlias,
              child: (_photoUrl != null && _photoUrl!.isNotEmpty)
                  ? Image.network(
                      _photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_outline,
                        size: 48,
                        color: AppColors.violet,
                      ),
                    )
                  : const Icon(Icons.person_outline, size: 48, color: AppColors.violet),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'ID photo on file with the school',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(
            child: StatusPill(label: 'Synced from school records', kind: StatusKind.positive),
          ),
          const SizedBox(height: AppSpacing.xl),

          _readOnlyRow(context, 'Full name', _name, Icons.badge_outlined),
          const SizedBox(height: AppSpacing.sm),
          _readOnlyRow(context, 'Admission number', _admissionNo, Icons.confirmation_number_outlined),
          const SizedBox(height: AppSpacing.sm),
          _readOnlyRow(context, 'Course', _course, Icons.school_outlined),

          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, size: 16, color: AppColors.inkPlum),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These details are set by the school and can\'t be edited here. To update your registered course, use Course registration.',
                    style: const TextStyle(fontSize: 12, color: AppColors.inkPlum, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyRow(BuildContext context, String label, String value, IconData icon) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '—' : value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
