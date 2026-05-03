import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password Strength Validation Tests', () {
    test('UT-2-1: Password must contain uppercase letter', () {
      final password = "password123!";
      final hasUppercase = password.contains(RegExp(r'[A-Z]'));
      expect(hasUppercase, false);
    });

    test('UT-2-2: Password must contain number', () {
      final password = "Password!";
      final hasNumber = password.contains(RegExp(r'[0-9]'));
      expect(hasNumber, false);
    });

    test('UT-2-3: Password must contain special character', () {
      final password = "Password123";
      final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      expect(hasSpecial, false);
    });

    test('UT-2-4: Valid password meets all requirements', () {
      final password = "Password123!";
      final hasUppercase = password.contains(RegExp(r'[A-Z]'));
      final hasNumber = password.contains(RegExp(r'[0-9]'));
      final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      final isLongEnough = password.length >= 6;

      expect(hasUppercase, true);
      expect(hasNumber, true);
      expect(hasSpecial, true);
      expect(isLongEnough, true);
    });

    test('UT-2-5: Password with uppercase, number, special, length passes', () {
      final password = "StrongPass@2024";
      final hasUppercase = password.contains(RegExp(r'[A-Z]'));
      final hasNumber = password.contains(RegExp(r'[0-9]'));
      final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      final isLongEnough = password.length >= 6;

      expect(hasUppercase, true);
      expect(hasNumber, true);
      expect(hasSpecial, true);
      expect(isLongEnough, true);
    });
  });
}
