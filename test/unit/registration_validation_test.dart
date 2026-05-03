import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Registration Validation Tests', () {
    test('UT-1-1: Name should not contain numbers', () {
      final name = "John123";
      final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
      final isValid = nameRegex.hasMatch(name);
      expect(isValid, false);
    });

    test('UT-1-2: Name should only contain letters and spaces', () {
      final validName = "John Doe";
      final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
      final isValid = nameRegex.hasMatch(validName);
      expect(isValid, true);
    });

    test('UT-1-3: Name must be at least 2 characters', () {
      final shortName = "J";
      final isValid = shortName.length >= 2;
      expect(isValid, false);
    });

    test('UT-1-4: Email must contain @ symbol', () {
      final email = "usermail.com";
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      final isValid = emailRegex.hasMatch(email);
      expect(isValid, false);
    });

    test('UT-1-5: Email must have valid format', () {
      final validEmail = "user@citycare.com";
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      final isValid = emailRegex.hasMatch(validEmail);
      expect(isValid, true);
    });

    test('UT-1-6: Password must be at least 6 characters', () {
      final shortPassword = "123";
      final isLongEnough = shortPassword.length >= 6;
      expect(isLongEnough, false);
    });

    test('UT-1-7: Phone must be 11 digits', () {
      final shortPhone = "123456789";
      final isValid = shortPhone.length == 11;
      expect(isValid, false);
    });

    test('UT-1-8: Phone must start with 03', () {
      final invalidPhone = "12345678901";
      final startsWith03 = invalidPhone.startsWith("03");
      expect(startsWith03, false);
    });

    test('UT-1-9: Valid phone number passes validation', () {
      final validPhone = "03001234567";
      final isValid = validPhone.length == 11 && validPhone.startsWith("03");
      expect(isValid, true);
    });
  });
}
