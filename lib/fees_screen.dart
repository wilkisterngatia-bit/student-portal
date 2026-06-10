import 'package:flutter/material.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

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
              'FEES STATEMENT',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(hintText: 'Total Billed Amount'),
            ),
            const SizedBox(height: 25),
            const TextField(
              decoration: InputDecoration(hintText: 'Amount Paid'),
            ),
            const SizedBox(height: 25),
            const TextField(
              decoration: InputDecoration(hintText: 'Outstanding Balance'),
            ),
            const SizedBox(height: 25),
            const TextField(
              decoration: InputDecoration(hintText: 'Bank Reference / Receipt No.'),
            ),
          ],
        ),
      ),
    );
  }
}