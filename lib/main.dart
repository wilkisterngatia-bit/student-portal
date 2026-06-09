import 'package:flutter/material.dart';
import 'login_screen.dart';

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