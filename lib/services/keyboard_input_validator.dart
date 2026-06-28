/// Result of a single validation check. Carrying both the pass/fail
/// flag and an explanatory message in one object — rather than just
/// returning a bool — is itself a small OOP design choice: the caller
/// gets a structured result it can act on, not just a yes/no.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid() : isValid = true, errorMessage = null;
  const ValidationResult.invalid(this.errorMessage) : isValid = false;
}

/// A dedicated class for keyboard/text input validation, used across
/// the app's forms (Exam registration, Course registration, Login)
/// instead of scattering ad-hoc `if (text.isEmpty)` checks through
/// each screen. Each method is a single-responsibility validation
/// rule that can be combined and reused.
///
/// This demonstrates the Week 8 principle of organizing input
/// handling into dedicated classes with clear methods, applied to
/// Flutter/Dart rather than the Python event-handler examples in the
/// lecture notes — the same OOP structure, different syntax.
class KeyboardInputValidator {
  /// Field must not be empty (after trimming whitespace).
  static ValidationResult validateRequired(String value, {String fieldName = 'This field'}) {
    if (value.trim().isEmpty) {
      return ValidationResult.invalid('$fieldName is required.');
    }
    return const ValidationResult.valid();
  }

  /// Field must contain only letters, numbers, and a fixed set of
  /// separators typical of unit codes and admission numbers (e.g.
  /// "BIT 4107", "BIT/2024/0456").
  static ValidationResult validateAlphanumericCode(String value, {String fieldName = 'This field'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.invalid('$fieldName is required.');
    }
    final pattern = RegExp(r'^[A-Za-z0-9 /\-]+$');
    if (!pattern.hasMatch(trimmed)) {
      return ValidationResult.invalid('$fieldName can only contain letters, numbers, spaces, "/" and "-".');
    }
    return const ValidationResult.valid();
  }

  /// Field must contain only digits (e.g. KES amounts, phone numbers).
  static ValidationResult validateNumeric(String value, {String fieldName = 'This field'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.invalid('$fieldName is required.');
    }
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return ValidationResult.invalid('$fieldName must contain numbers only.');
    }
    return const ValidationResult.valid();
  }

  /// Field must be at least [minLength] characters once trimmed —
  /// used for free-text reasons (e.g. exam registration justification)
  /// so a one-character non-answer doesn't pass as a valid reason.
  static ValidationResult validateMinLength(String value, int minLength, {String fieldName = 'This field'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.invalid('$fieldName is required.');
    }
    if (trimmed.length < minLength) {
      return ValidationResult.invalid('$fieldName must be at least $minLength characters.');
    }
    return const ValidationResult.valid();
  }

  /// Basic structural email check — not exhaustive RFC validation,
  /// but enough to catch obviously malformed input.
  static ValidationResult validateEmail(String value, {String fieldName = 'Email'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.invalid('$fieldName is required.');
    }
    final pattern = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(trimmed)) {
      return ValidationResult.invalid('Enter a valid $fieldName.');
    }
    return const ValidationResult.valid();
  }

  /// Runs multiple validators in order against the same value and
  /// returns the first failure, or a pass if all succeed. This lets
  /// callers compose rules (e.g. "required AND alphanumeric") without
  /// writing their own control flow.
  static ValidationResult validateAll(String value, List<ValidationResult Function(String)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (!result.isValid) return result;
    }
    return const ValidationResult.valid();
  }
}
