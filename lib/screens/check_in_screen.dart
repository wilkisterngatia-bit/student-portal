import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import 'live_session_screen.dart';

/// Attendance check-in step for online classes.
///
/// Sits between "Join" on the Timetable and the actual live session.
/// Reuses the same image_picker capture logic as the old standalone
/// Camera screen, but repurposed here as proof-of-attendance: the
/// student must take a check-in photo before they're allowed into
/// the session. This is not a top-level tab — it only appears as a
/// step inside the Join flow, the way attendance check-in works on
/// a real school portal.
class CheckInScreen extends StatefulWidget {
  final String unit;
  final String day;
  final String time;

  const CheckInScreen({
    super.key,
    required this.unit,
    required this.day,
    required this.time,
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _isCapturing = false;
  String? _errorMessage;

  Future<void> _capturePhoto() async {
    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (!mounted) return;

      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _isCapturing = false;
        });
      } else {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _errorMessage =
            'Camera unavailable. On Chrome, use "Pick from gallery" instead — '
            'the full camera shutter is only available on a physical device.';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _isCapturing = false;
        });
      } else {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Could not access gallery. Check app permissions.';
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _errorMessage = null;
    });
  }

  void _confirmAndJoin() {
    // In a full build this is where the photo (or just a
    // checked-in timestamp+flag) would be attached to this
    // session's attendance record via an API call. For now we
    // carry the check-in fact forward by simply proceeding into
    // the live session — the record-keeping call is a one-line
    // addition once the attendance API supports it.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSessionScreen(
          unit: widget.unit,
          day: widget.day,
          time: widget.time,
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: kIsWeb
          ? Image.network(
              _capturedImage!.path,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 240,
                color: AppColors.violetSoft,
                alignment: Alignment.center,
                child: const Text('Image preview unavailable on web'),
              ),
            )
          : Image.file(
              File(_capturedImage!.path),
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _capturedImage != null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                  eyebrow: 'ATTENDANCE CHECK-IN', title: 'Confirm it\'s you'),
              const SizedBox(height: 4),
              Text(
                'Take a quick photo to check in before joining ${widget.unit}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Session summary card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.videocam_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.unit,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.day} · ${widget.time}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              if (!hasPhoto) ...[
                ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _capturePhoto,
                  icon: _isCapturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.camera_alt, size: 20),
                  label: Text(
                      _isCapturing ? 'Opening camera...' : 'Take check-in photo'),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isCapturing ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Pick from gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.violet,
                      side: const BorderSide(color: AppColors.violet),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ),
              ] else ...[
                _buildPreview(),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.sage),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Check-in photo captured',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: _confirmAndJoin,
                  icon: const Icon(Icons.login, size: 20),
                  label: const Text('Confirm & join class'),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _retakePhoto,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retake photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.violet,
                      side: const BorderSide(color: AppColors.violet),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.amber,
                                height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}