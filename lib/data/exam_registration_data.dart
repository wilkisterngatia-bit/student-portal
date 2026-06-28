enum ExamType { firstAttempt, special, retake, reRetake }

class ExamTypeInfo {
  final ExamType type;
  final String label;
  final String description;
  final bool requiresReason;
  final bool requiresEvidence;
  final int feePerUnit;
  final String? notice;

  const ExamTypeInfo({
    required this.type,
    required this.label,
    required this.description,
    this.requiresReason = false,
    this.requiresEvidence = false,
    this.feePerUnit = 0,
    this.notice,
  });
}

class ExamRegistrationData {
  ExamRegistrationData._();

  static const List<ExamTypeInfo> types = [
    ExamTypeInfo(
      type: ExamType.firstAttempt,
      label: 'First attempt',
      description: 'Standard registration for units you are taking this semester.',
      feePerUnit: 0,
    ),
    ExamTypeInfo(
      type: ExamType.special,
      label: 'Special exam',
      description: 'For a first sitting missed due to illness or another valid cause.',
      requiresReason: true,
      requiresEvidence: true,
      feePerUnit: 1000,
      notice: 'Supporting evidence (e.g. a medical certificate) is required and will be reviewed by the exams office.',
    ),
    ExamTypeInfo(
      type: ExamType.retake,
      label: 'Retake',
      description: 'For a unit you sat once before and did not pass.',
      requiresReason: false,
      feePerUnit: 1500,
      notice: 'Retake fee applies per unit. You may only retake a unit you have previously failed.',
    ),
    ExamTypeInfo(
      type: ExamType.reRetake,
      label: 'Re-retake',
      description: 'For a unit you have already retaken once and still not passed.',
      requiresReason: true,
      feePerUnit: 2500,
      notice: 'Re-retakes require Dean\'s approval and carry a higher fee. Maximum of one re-retake per unit.',
    ),
  ];

  static ExamTypeInfo infoFor(ExamType type) =>
      types.firstWhere((t) => t.type == type);
}
