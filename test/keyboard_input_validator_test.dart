// test/keyboard_input_validator_test.dart
//
// Unit tests for KeyboardInputValidator.
// This is the Flutter/Dart equivalent of a JUnit test class: flutter_test's
// test() + expect() play the same role as JUnit's @Test + assertEquals().
//
// Run with:  flutter test test/keyboard_input_validator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:student_portal_app/services/keyboard_input_validator.dart';

void main() {
  group('validateRequired', () {
    test('returns invalid for an empty string', () {
      final result = KeyboardInputValidator.validateRequired('', fieldName: 'Unit code');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Unit code is required.');
    });

    test('returns invalid for a whitespace-only string', () {
      final result = KeyboardInputValidator.validateRequired('   ');
      expect(result.isValid, false);
    });

    test('returns valid for non-empty text', () {
      final result = KeyboardInputValidator.validateRequired('BIT 4107');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('validateEmail', () {
    test('returns valid for a properly formatted email', () {
      final result = KeyboardInputValidator.validateEmail('student@mku.ac.ke');
      expect(result.isValid, true);
    });

    test('returns invalid for a malformed email (missing domain)', () {
      final result = KeyboardInputValidator.validateEmail('student@');
      expect(result.isValid, false);
    });

    test('returns invalid for text with no @ symbol', () {
      final result = KeyboardInputValidator.validateEmail('notanemail');
      expect(result.isValid, false);
    });
  });

  group('validateMinLength', () {
    test('returns invalid when text is shorter than the minimum', () {
      final result = KeyboardInputValidator.validateMinLength('short', 10, fieldName: 'Reason');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Reason must be at least 10 characters.');
    });

    test('returns valid when text is exactly the minimum length (boundary case)', () {
      // Exactly 10 characters — this is the edge case that exposes an
      // off-by-one bug if one is ever introduced into the comparison.
      final result = KeyboardInputValidator.validateMinLength('1234567890', 10);
      expect(result.isValid, true);
    });

    test('returns valid when text is longer than the minimum', () {
      final result = KeyboardInputValidator.validateMinLength(
        'This is a sufficiently long justification.',
        10,
      );
      expect(result.isValid, true);
    });
  });
}