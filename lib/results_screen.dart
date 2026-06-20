
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<dynamic> _mockExamResults = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOnlineResults();
  }

  // Week 5 Concept: Asynchronous GET request handling JSON data
  Future<void> _fetchOnlineResults() async {
    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=4');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> downloadedData = json.decode(response.body);
        
        setState(() {
          _mockExamResults = downloadedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network timeout or slow connection.';
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXAM RESULTS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _mockExamResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 30, color: Colors.black),
                  itemBuilder: (context, index) {
                    final item = _mockExamResults[index];
                    String unitCode = "BIT ${4101 + index}";
                    int mockMark = 85 - (index * 4); 

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed the alignment naming here!
                        children: [
                          Text(
                            unitCode,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Grade: $mockMark% (${mockMark >= 80 ? "A" : "B"})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
