import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_field.dart';
import '../widgets/screen_header.dart';
import '../services/course_registration_store.dart';

class CourseRegistrationScreen extends StatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  State<CourseRegistrationScreen> createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final List<String> _units = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentCourse();
  }

  Future<void> _loadCurrentCourse() async {
    final course = await CourseRegistrationStore.getCurrentCourse();
    if (mounted && course != null) {
      setState(() {
        _courseController.text = course;
      });
    }
  }

  void _addUnit() {
    final unit = _unitController.text.trim();
    if (unit.isEmpty) return;
    setState(() {
      _units.add(unit);
      _unitController.clear();
    });
  }

  void _removeUnit(int index) {
    setState(() => _units.removeAt(index));
  }

  Future<void> _submit() async {
    final course = _courseController.text.trim();
    if (course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the course you\'re registering under.')),
      );
      return;
    }
    if (_semesterController.text.trim().isEmpty || _units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a semester and at least one unit first.')),
      );
      return;
    }

    await CourseRegistrationStore.setCurrentCourse(course);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered ${_units.length} unit(s) for ${_semesterController.text}')),
    );
  }

  @override
  void dispose() {
    _courseController.dispose();
    _semesterController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(eyebrow: 'ACADEMICS', title: 'Course registration'),
              const SizedBox(height: 4),
              Text(
                'Your registered course here also updates what shows on your Profile.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              LabeledField(
                label: 'Course',
                controller: _courseController,
                hint: 'e.g. BSc. Information Technology',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledField(
                label: 'Semester',
                controller: _semesterController,
                hint: 'e.g. Year 2, Semester 1',
                icon: Icons.event_note_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Unit code', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      onSubmitted: (_) => _addUnit(),
                      decoration: const InputDecoration(hintText: 'e.g. BIT 4107'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    height: 54,
                    width: 54,
                    child: ElevatedButton(
                      onPressed: _addUnit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.inkPlum,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_units.isNotEmpty) ...[
                Text('Units added (${_units.length})',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_units.length, (i) {
                    return Chip(
                      label: Text(_units[i]),
                      backgroundColor: AppColors.violetSoft,
                      labelStyle: const TextStyle(
                          color: AppColors.inkPlum, fontWeight: FontWeight.w600),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeUnit(i),
                      side: BorderSide.none,
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.xl),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'No units added yet. Type a unit code above and tap +.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}