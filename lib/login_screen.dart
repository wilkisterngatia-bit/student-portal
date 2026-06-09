import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'STUDENT PORTAL',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Username Input
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.person_outline, color: Colors.black, size: 30),
                    prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 30),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Password Input
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.black, size: 30),
                    prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 30),
                  ),
                ),
                const SizedBox(height: 50),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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