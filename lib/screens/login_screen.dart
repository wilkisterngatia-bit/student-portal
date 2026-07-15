import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_field.dart';
import '../services/auth_state.dart';
import '../services/auth_api.dart';
import '../services/location_service.dart';
import 'dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your username and password to continue.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      // Sends the login as a real HTTP POST with the password hashed
      // before transmission — see AuthApi for the full explanation.
      final success = await AuthApi.login(username, password);

      if (!mounted) return;

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_username', username);
        await prefs.setBool('is_logged_in', true);

        // Another async gap happened above (SharedPreferences calls),
        // so re-check mounted right before touching context/Navigator —
        // the earlier check only covers the AuthApi.login gap.
        if (!mounted) return;

        AuthState.login();

        // Fire-and-forget: captures GPS location in the background as
        // login evidence. Deliberately not awaited — a slow or denied
        // location fetch should never delay getting into the app.
        LocationService.captureLoginLocation();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _loading = false;
          _error = 'That username or password doesn\'t match our records.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not reach the login server. Check your connection and try again.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
                        child: const Icon(Icons.school_outlined,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Student Portal',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to view your courses, results, and fees',
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
                        label: 'Username',
                        controller: _usernameController,
                        hint: 'e.g. admin',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LabeledField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        obscureText: _obscure,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
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
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                                  ),
                          child: const Text("Don't have an account? Register"),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Text(
                          'Demo access — username: admin · password: admin123',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
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