import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  String _totalBilled = "Loading...";
  String _amountPaid = "Loading...";
  String _balance = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeesStatement();
  }

  Future<void> _fetchFeesStatement() async {
    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/users/1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // We simulate a financial ledger structure using incoming unique user data numbers
        int userIdMultiplier = data['id'] * 15000; 
        
        setState(() {
          _totalBilled = "KES ${userIdMultiplier + 35000}.00";
          _amountPaid = "KES $userIdMultiplier.00";
          _balance = "KES 35,000.00";
          _isLoading = false;
        });
      } else {
        setState(() {
          _totalBilled = "Error loading";
          _amountPaid = "Error loading";
          _balance = "Error loading";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _totalBilled = "Offline";
        _amountPaid = "Offline";
        _balance = "Offline";
        _isLoading = false;
      });
    }
  }

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
            _buildStaticStatementLine('Total Billed Amount', _totalBilled),
            const SizedBox(height: 30),
            _buildStaticStatementLine('Amount Paid', _amountPaid),
            const SizedBox(height: 30),
            _buildStaticStatementLine('Outstanding Balance', _balance),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticStatementLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        const Divider(color: Colors.black, thickness: 1),
      ],
    );
  }
}