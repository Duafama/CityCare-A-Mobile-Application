import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_care/main.dart'; // یہ آپ کے package name سے مطابقت رکھے

void main() {
  testWidgets('Welcome screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CityCareApp()); // MyApp سے CityCareApp کر دیں

    // Verify that welcome screen appears
    expect(find.text('City Care'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('Navigate to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CityCareApp());
    
    // Tap on login button (assuming welcome screen has login button)
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify that we're on login screen
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields
  });

  testWidgets('Navigate to register screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CityCareApp());
    
    // Tap on register button
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Verify that we're on register screen
    expect(find.text('Create Account'), findsOneWidget);
  });
}