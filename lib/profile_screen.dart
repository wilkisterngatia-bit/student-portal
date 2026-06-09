import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile wireframe placeholder matching Figma line art
            Center(
              child: Icon(
                Icons.account_circle_outlined,
                size: 140,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 50),
            
            // Name Field
            const TextField(
              decoration: InputDecoration(
                hintText: 'Name',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 25),
            
            // Admission Number Field
            const TextField(
              decoration: InputDecoration(
                hintText: 'Admission No.',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 25),
            
            // Course Field
            const TextField(
              decoration: InputDecoration(
                hintText: 'Course',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}