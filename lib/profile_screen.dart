import 'package:flutter/material.dart';
import 'database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _adminController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredProfileData();
  }

  Future<void> _loadStoredProfileData() async {
    final studentRecords = await DatabaseHelper.instance.getStudents();
    if (studentRecords.isNotEmpty) {
      final lastSavedRecord = studentRecords.last;
      setState(() {
        _nameController.text = lastSavedRecord['name'] ?? '';
        _adminController.text = lastSavedRecord['admission_no'] ?? '';
        _courseController.text = lastSavedRecord['course'] ?? '';
      });
    }
  }

  Future<void> _saveProfileData() async {
    if (_nameController.text.isNotEmpty) {
      await DatabaseHelper.instance.deleteAllStudents();
      
      Map<String, dynamic> studentDataRow = {
        'name': _nameController.text,
        'admission_no': _adminController.text,
        'course': _courseController.text,
      };

      await DatabaseHelper.instance.insertStudent(studentDataRow);
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
          onPressed: () async {
            await _saveProfileData();
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 140,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _adminController,
                decoration: const InputDecoration(
                  hintText: 'Admission No.',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _courseController,
                decoration: const InputDecoration(
                  hintText: 'Course',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Data will automatically save to SQLite storage when navigating back.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12, 
                  color: Colors.grey.shade600, 
                  fontStyle: FontStyle.italic // Fixed the typo here!
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}