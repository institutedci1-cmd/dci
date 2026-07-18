import 'package:flutter_test/flutter_test.dart';
import 'package:d_c_i_teacher_app/shared/form_validator.dart';

void main() {
  group('FormValidator Tests', () {
    test('validateRequired returns error for empty string', () {
      final result = FormValidator.validateRequired('', 'Name');
      expect(result, 'Name is required');
    });

    test('validateRequired returns null for non-empty string', () {
      final result = FormValidator.validateRequired('John Doe', 'Name');
      expect(result, isNull);
    });

    test('validateEmail returns error for invalid email', () {
      final result = FormValidator.validateEmail('invalid-email');
      expect(result, 'Enter a valid email address');
    });

    test('validateEmail returns null for valid email', () {
      final result = FormValidator.validateEmail('test@example.com');
      expect(result, isNull);
    });

    test('validatePhone returns error for invalid phone', () {
      final result = FormValidator.validatePhone('123');
      expect(result, 'Enter a valid phone number');
    });

    test('validatePhone returns null for valid phone', () {
      final result = FormValidator.validatePhone('9876543210');
      expect(result, isNull);
    });
  });
}
