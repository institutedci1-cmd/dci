import 'package:flutter_test/flutter_test.dart';
import 'package:d_c_i_teacher_app/backend/services/validation_service.dart';

void main() {
  group('ValidationService Tests', () {
    test('validateRequired returns error for empty string', () {
      final result = ValidationService.validateRequired('', 'Name');
      expect(result, 'Name is required.');
    });

    test('validateRequired returns null for non-empty string', () {
      final result = ValidationService.validateRequired('John Doe', 'Name');
      expect(result, isNull);
    });

    test('validateEmail returns error for invalid email', () {
      final result = ValidationService.validateEmail('invalid-email');
      expect(result, 'Enter a valid email address.');
    });

    test('validateEmail returns null for valid email', () {
      final result = ValidationService.validateEmail('test@example.com');
      expect(result, isNull);
    });

    test('validatePhoneNumber returns error for invalid phone', () {
      final result = ValidationService.validatePhoneNumber('123');
      expect(result, 'Enter a valid 10-12 digit phone number.');
    });

    test('validatePhoneNumber returns null for valid phone', () {
      final result = ValidationService.validatePhoneNumber('9876543210');
      expect(result, isNull);
    });

    test('validateNumber returns error for non-numeric string', () {
      final result = ValidationService.validateNumber('abc', 'Marks');
      expect(result, 'Marks must be a valid number.');
    });

    test('validateNumber returns null for numeric string', () {
      final result = ValidationService.validateNumber('100', 'Marks');
      expect(result, isNull);
    });
  });
}
