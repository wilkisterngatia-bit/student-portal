import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'widgets/floating_assistant.dart';
import 'services/auth_state.dart';
=======
<<<<<<< HEAD
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
=======
import 'login_screen.dart';
>>>>>>> 7de35c6ef55132e17ba779805cc2361332f87395
>>>>>>> 0bafda798c711ccdbff03b4e01897423b69b639f

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
<<<<<<< HEAD
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
=======
<<<<<<< HEAD
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}
=======
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor:   const Color(0xFF7A4F93), // Your Figma Purple theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A4F93),
          primary: const Color(0xFF7A4F93),
        ),
        // Global styling for the minimalistic bottom-border input fields
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
>>>>>>> 7de35c6ef55132e17ba779805cc2361332f87395
>>>>>>> 0bafda798c711ccdbff03b4e01897423b69b639f
