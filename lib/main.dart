import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'widgets/floating_assistant.dart';
import 'services/auth_state.dart';

void main() {
  runApp(const StudentPortalApp());
}

class StudentPortalApp extends StatelessWidget {
  const StudentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Portal',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginScreen(),
      // The builder wraps every screen the navigator pushes, so the
      // floating assistant bubble sits on top of the whole app and
      // persists across navigation, rather than belonging to any one
      // screen. It only appears once the student is signed in.
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            ValueListenableBuilder<bool>(
              valueListenable: AuthState.isLoggedIn,
              builder: (context, loggedIn, _) {
                if (!loggedIn) return const SizedBox.shrink();
                return const FloatingAssistant();
              },
            ),
          ],
        );
      },
    );
  }
}
