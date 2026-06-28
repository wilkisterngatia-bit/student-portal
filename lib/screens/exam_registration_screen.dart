import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../data/exam_registration_data.dart';
import '../services/exam_registration_store.dart';
import '../services/keyboard_input_validator.dart';

class ExamRegistrationScreen extends StatefulWidget {
  const ExamRegistrationScreen({super.key});

  @override
  State<ExamRegistrationScreen> createState() => _ExamRegistrationScreenState();
}

class _ExamRegistrationScreenState extends State<ExamRegistrationScreen> {
  ExamType _selectedType = ExamType.firstAttempt;
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _evidenceAttached = false;
  List<ExamRegistrationEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await ExamRegistrationStore.getAll();
    if (mounted) setState(() => _history = entries);
  }

  Future<void> _submit() async {
    final info = ExamRegistrationData.infoFor(_selectedType);
    final unit = _unitController.text.trim();

    // Replaces ad-hoc isEmpty checks with the dedicated
    // KeyboardInputValidator class, demonstrating reusable,
    // class-based input validation rather than inline conditionals
    // duplicated across every form in the app.
    final unitResult = KeyboardInputValidator.validateAlphanumericCode(
      unit, fieldName: 'Unit code',
    );
    if (!unitResult.isValid) {
      _showSnack(unitResult.errorMessage!);
      return;
    }

    if (info.requiresReason) {
      final reasonResult = KeyboardInputValidator.validateMinLength(
        _reasonController.text, 10, fieldName: 'Reason',
      );
      if (!reasonResult.isValid) {
        _showSnack(reasonResult.errorMessage!);
        return;
      }
    }

    if (info.requiresEvidence && !_evidenceAttached) {
      _showSnack('Please attach supporting evidence before submitting.');
      return;
    }

    await ExamRegistrationStore.add(ExamRegistrationEntry(
      type: _selectedType,
      unitCode: unit,
      reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
      submittedAt: DateTime.now(),
    ));

    _unitController.clear();
    _reasonController.clear();
    setState(() => _evidenceAttached = false);
    await _loadHistory();

    if (!mounted) return;
    _showSnack('${info.label} registration submitted for $unit.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _unitController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ExamRegistrationData.infoFor(_selectedType);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const ScreenHeader(eyebrow: 'ACADEMICS', title: 'Exam registration'),
            const SizedBox(height: AppSpacing.lg),

            Text('Exam type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExamRegistrationData.types.map((t) {
                final selected = t.type == _selectedType;
                return ChoiceChip(
                  label: Text(t.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedType = t.type),
                  selectedColor: AppColors.violet,
                  backgroundColor: AppColors.card,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(color: selected ? AppColors.violet : AppColors.divider),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.md),
            Text(info.description, style: Theme.of(context).textTheme.bodyMedium),

            if (info.notice != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        info.notice!,
                        style: const TextStyle(fontSize: 12, color: AppColors.amber, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            Text('Unit code', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(hintText: 'e.g. BIT 4107'),
            ),

            if (info.requiresReason) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Reason', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Briefly explain why you are applying for this exam type',
                ),
              ),
            ],

            if (info.requiresEvidence) ...[
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () => setState(() => _evidenceAttached = !_evidenceAttached),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _evidenceAttached ? AppColors.sageSoft : AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: _evidenceAttached ? AppColors.sage : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _evidenceAttached ? Icons.check_circle : Icons.attach_file,
                        size: 18,
                        color: _evidenceAttached ? AppColors.sage : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _evidenceAttached
                              ? 'Evidence attached'
                              : 'Attach supporting evidence',
                          style: TextStyle(
                            fontSize: 13,
                            color: _evidenceAttached ? AppColors.sage : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            if (info.feePerUnit > 0)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fee for this registration',
                        style: TextStyle(fontSize: 13, color: AppColors.inkPlum)),
                    Text('KES ${info.feePerUnit}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.inkPlum)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.sageSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fee for this registration', style: TextStyle(fontSize: 13, color: AppColors.sage)),
                    Text('Free', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.sage)),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit registration'),
            ),

            if (_history.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Your submissions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ..._history.map((entry) {
                final info = ExamRegistrationData.infoFor(entry.type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.unitCode, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(
                                '${info.label} · ${DateFormat('MMM d, h:mm a').format(entry.submittedAt)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.amberSoft,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Text('Pending',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.amber)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
