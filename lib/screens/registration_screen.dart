import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_field.dart';
import '../services/auth_api.dart';
import '../services/keyboard_input_validator.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    // Compose validators using the existing KeyboardInputValidator
    // class from Week 8, rather than writing new ad-hoc checks.
    final nameResult = KeyboardInputValidator.validateRequired(name, fieldName: 'Full name');
    if (!nameResult.isValid) {
      setState(() => _error = nameResult.errorMessage);
      return;
    }

    final usernameResult = KeyboardInputValidator.validateRequired(username, fieldName: 'Username');
    if (!usernameResult.isValid) {
      setState(() => _error = usernameResult.errorMessage);
      return;
    }

    final passwordResult = KeyboardInputValidator.validateMinLength(
      password,
      6,
      fieldName: 'Password',
    );
    if (!passwordResult.isValid) {
      setState(() => _error = passwordResult.errorMessage);
      return;
    }

    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final success = await AuthApi.register(username, password);

      if (!mounted) return;

      if (success) {
        // Registration complete — send them to Login to sign in with
        // their new credentials, rather than auto-logging in, so the
        // full register -> login flow is visibly demonstrated.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created — sign in to continue.')),
        );
      } else {
        setState(() {
          _loading = false;
          _error = 'That username is already taken. Try another.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not reach the server. Check your connection and try again.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 56, AppSpacing.lg, 40),
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person_add_alt_1_outlined,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Create Account',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Register to access your student portal',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledField(
                        label: 'Full name',
                        controller: _nameController,
                        hint: 'e.g. Wilkester Ngatia',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LabeledField(
                        label: 'Username',
                        controller: _usernameController,
                        hint: 'Choose a username',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LabeledField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: 'At least 6 characters',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LabeledField(
                        label: 'Confirm password',
                        controller: _confirmController,
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 16, color: AppColors.coral),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                    color: AppColors.coral, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton(
                        onPressed: _loading ? null : _handleRegister,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  ),
                          child: const Text('Already have an account? Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}