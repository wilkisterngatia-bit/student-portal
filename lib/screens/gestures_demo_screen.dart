import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../services/gesture_handler_service.dart';
import '../services/keyboard_input_validator.dart';

/// Demonstrates the Week 8 brief directly: dedicated classes for
/// touch gesture handling (GestureHandlerService) and keyboard input
/// validation (KeyboardInputValidator), both exercised live so every
/// gesture type and validation rule is visibly working, not just
/// present in code.
class GesturesDemoScreen extends StatefulWidget {
  const GesturesDemoScreen({super.key});

  @override
  State<GesturesDemoScreen> createState() => _GesturesDemoScreenState();
}

class _GesturesDemoScreenState extends State<GesturesDemoScreen> {
  late final GestureHandlerService _gestureHandler;
  final List<GestureEvent> _log = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _ageError;

  @override
  void initState() {
    super.initState();
    // The screen owns one GestureHandlerService instance and routes
    // every recognized gesture into _onGesture, rather than wiring
    // separate inline callbacks for tap/double-tap/long-press/swipe.
    _gestureHandler = GestureHandlerService(onGesture: _onGesture);
  }

  void _onGesture(GestureEvent event) {
    setState(() {
      _log.insert(0, event);
      if (_log.length > 8) _log.removeLast();
    });
  }

  Color _colorFor(GestureType type) {
    switch (type) {
      case GestureType.tap:
        return AppColors.violet;
      case GestureType.doubleTap:
        return AppColors.sage;
      case GestureType.longPress:
        return AppColors.coral;
      case GestureType.swipeLeft:
      case GestureType.swipeRight:
      case GestureType.swipeUp:
      case GestureType.swipeDown:
        return AppColors.teal;
    }
  }

  IconData _iconFor(GestureType type) {
    switch (type) {
      case GestureType.tap:
        return Icons.touch_app_outlined;
      case GestureType.doubleTap:
        return Icons.fingerprint;
      case GestureType.longPress:
        return Icons.timer_outlined;
      case GestureType.swipeLeft:
        return Icons.arrow_back;
      case GestureType.swipeRight:
        return Icons.arrow_forward;
      case GestureType.swipeUp:
        return Icons.arrow_upward;
      case GestureType.swipeDown:
        return Icons.arrow_downward;
    }
  }

  /// Runs the dedicated KeyboardInputValidator class against every
  /// field and updates the on-screen error messages. This is called
  /// on every keystroke (onChanged) so the form behaves like a real
  /// keyboard-input handler rather than only validating on submit.
  void _validateForm() {
    setState(() {
      _nameError = KeyboardInputValidator.validateMinLength(
        _nameController.text, 2, fieldName: 'Name',
      ).errorMessage;

      _emailError = KeyboardInputValidator.validateEmail(
        _emailController.text,
      ).errorMessage;

      _ageError = KeyboardInputValidator.validateNumeric(
        _ageController.text, fieldName: 'Age',
      ).errorMessage;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const ScreenHeader(eyebrow: 'INPUT & GESTURES', title: 'Gestures & input demo'),
            const SizedBox(height: 4),
            Text(
              'Tap, double-tap, long-press, or swipe the box below.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // The gesture pad: a single widget wrapped by the
            // GestureHandlerService, recognizing every gesture type.
            _gestureHandler.wrap(
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pan_tool_outlined, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Try any gesture here',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text('Recognized gestures', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            if (_log.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: Text(
                    'No gestures yet \u2014 interact with the box above.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ..._log.map((event) {
                final color = _colorFor(event.type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(_iconFor(event.type), size: 16, color: color),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(event.label, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Text(
                          '${event.timestamp.hour.toString().padLeft(2, '0')}:'
                          '${event.timestamp.minute.toString().padLeft(2, '0')}:'
                          '${event.timestamp.second.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: AppSpacing.xl),
            Text('Live keyboard input validation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Validated on every keystroke using KeyboardInputValidator.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            _validatedField(
              label: 'Name',
              controller: _nameController,
              hint: 'At least 2 characters',
              error: _nameError,
            ),
            const SizedBox(height: AppSpacing.md),
            _validatedField(
              label: 'Email',
              controller: _emailController,
              hint: 'e.g. you@example.com',
              error: _emailError,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            _validatedField(
              label: 'Age',
              controller: _ageController,
              hint: 'Numbers only',
              error: _ageError,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _validatedField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? error,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isValid = controller.text.isNotEmpty && error == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => _validateForm(),
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            suffixIcon: controller.text.isEmpty
                ? null
                : Icon(
                    isValid ? Icons.check_circle : Icons.error_outline,
                    color: isValid ? AppColors.sage : AppColors.coral,
                    size: 20,
                  ),
          ),
        ),
      ],
    );
  }
}
