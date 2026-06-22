import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CLASS TIMETABLE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(hintText: 'Select Day (e.g., Monday)'),
            ),
            const SizedBox(height: 25),
            const TextField(
              decoration: InputDecoration(hintText: 'Class Time slot'),
            ),
            const SizedBox(height: 25),
            const TextField(
              decoration: InputDecoration(hintText: 'Room / Lecture Hall'),
            ),
          ],
        ),
      ),
    );
  }
}