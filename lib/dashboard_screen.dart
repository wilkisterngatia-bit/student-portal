import 'package:flutter/material.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of dashboard button features matching your UI layout
    final List<Map<String, dynamic>> features = [
      {'title': 'Student Profile', 'route': const ProfileScreen()},
      {'title': 'Course Registration', 'route': null},
      {'title': 'Results', 'route': null},
      {'title': 'Fees', 'route': null},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'DASHBOARD',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // 2x2 Grid for top features
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _buildDashboardCard(
                    context, 
                    features[index]['title'], 
                    features[index]['route']
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Center-aligned Timetables button below the grid
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5 * (1 / 1.4),
                  child: _buildDashboardCard(context, 'Timetables', null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, Widget? targetScreen) {
    return InkWell(
      onTap: () {
        if (targetScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title screen connection coming soon!')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}