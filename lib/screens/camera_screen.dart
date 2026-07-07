import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';

/// Week 9 — Camera Integration.
///
/// Demonstrates how a mobile application accesses the device camera
/// to capture photos and display them within the app. Uses the
/// image_picker package, which launches the phone's native camera
/// app (or a file picker on web), handles runtime permission
/// requests automatically, and returns the captured image file for
/// display — exactly the pattern described in the Week 9 brief
/// (request permission → launch camera → capture image → display).
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
      // Launches the device camera. On physical Android/iOS, this
      // opens the native camera app and waits for the student to
      // take a photo. On Chrome web, it opens a file picker since
      // browsers don't expose a camera shutter API.
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (!mounted) return;

      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _isCapturing = false;
        });
      } else {
        // User cancelled — no photo taken.
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

  void _clearPhoto() {
    setState(() {
      _capturedImage = null;
      _errorMessage = null;
    });
  }

  Widget _buildImageDisplay() {
    if (_capturedImage == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text('Captured photo', style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: kIsWeb
              ? Image.network(
                  _capturedImage!.path,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: AppColors.violetSoft,
                    alignment: Alignment.center,
                    child: const Text('Image preview unavailable on web'),
                  ),
                )
              : Image.file(
                  File(_capturedImage!.path),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Photo metadata
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _metaRow(Icons.image_outlined, 'File name',
                  _capturedImage!.name),
              const SizedBox(height: AppSpacing.sm),
              _metaRow(Icons.check_circle_outline, 'Status',
                  'Successfully captured'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _clearPhoto,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Clear photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral,
              side: const BorderSide(color: AppColors.coral),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.violet),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                  eyebrow: 'DEVICE FEATURES', title: 'Camera'),
              const SizedBox(height: 4),
              Text(
                'Capture a photo using the device camera.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Camera info card
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Device camera',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          SizedBox(height: 2),
                          Text(
                            'Opens native camera app to capture photos',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Capture button
              ElevatedButton.icon(
                onPressed: _isCapturing ? null : _capturePhoto,
                icon: _isCapturing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.camera_alt, size: 20),
                label: Text(_isCapturing ? 'Opening camera...' : 'Capture photo'),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Gallery fallback
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

              _buildImageDisplay(),

              const SizedBox(height: AppSpacing.xl),

              // How it works explanation
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.inkPlum),
                        SizedBox(width: 8),
                        Text('How camera integration works',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkPlum)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _stepRow('1', 'App requests camera permission from the OS'),
                    _stepRow('2', 'OS launches the native camera app'),
                    _stepRow('3', 'Student captures the photo'),
                    _stepRow('4', 'Image is returned to the app and displayed'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.inkPlum,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkPlum,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
