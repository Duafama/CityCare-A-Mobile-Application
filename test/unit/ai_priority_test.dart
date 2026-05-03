import 'package:flutter_test/flutter_test.dart';
import 'package:city_care/services/ai_priority_service.dart';

void main() {
  group('AI Priority Suggestion Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('UT-10-1: Fire keyword should return High priority', () async {
      final description = 'Fire in the market area';
      final category = 'Emergency';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, 'High');
    });

    test('UT-10-2: Accident keyword should return High priority', () async {
      final description = 'Accident on highway blocking traffic';
      final category = 'Safety';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, 'High');
    });

    test('UT-10-3: Pothole keyword should return Medium priority', () async {
      final description = 'Large pothole on Main Street';
      final category = 'Roads';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, 'Medium');
    });

    test('UT-10-4: Garbage keyword should return Medium priority', () async {
      final description = 'Overflowing garbage bin on street corner';
      final category = 'Waste Management';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, 'Medium');
    });

    test('UT-10-5: Graffiti keyword should return Low priority', () async {
      final description = 'Graffiti on the wall of the park';
      final category = 'Beautification';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, 'Low');
    });

    test('UT-10-7: Water quality issue should not be High priority', () async {
      final description = 'Water is not clean and dirty';
      final category = 'Water';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, isNot('High'));
    });

    test('UT-10-8: Unknown description defaults to Medium', () async {
      final description = 'This area needs some attention';
      final category = 'Other';
      final priority = await AIService.getPriority(
        description: description,
        category: category,
        imageUrls: [],
      );
      expect(priority, 'Medium');
    });
  });
}
