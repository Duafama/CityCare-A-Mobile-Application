import 'package:flutter_test/flutter_test.dart';
import 'package:city_care/services/AIService.dart';

void main() {
  group('AIService Comment Moderation Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('UT-9-1: Comment with English bad word should return false', () async {
      final badComment = 'This work is stupid';
      final result = await aiService.moderateComment(badComment);
      expect(result, false);
    });

    test('UT-9-2: Comment with Urdu bad word should return false', () async {
      final urduBadComment = 'Ye kaam bakwas hai';
      final result = await aiService.moderateComment(urduBadComment);
      expect(result, false);
    });

    test('UT-9-3: Comment with government keyword should return false',
        () async {
      final govComment = 'The government should take action';
      final result = await aiService.moderateComment(govComment);
      expect(result, false);
    });

    test('UT-9-4: Comment with minister keyword should return false', () async {
      final ministerComment = 'The minister is not doing his job';
      final result = await aiService.moderateComment(ministerComment);
      expect(result, false);
    });

    test('UT-9-5: Comment with multiple bad words should return false',
        () async {
      final multipleBadComment = 'This is stupid and nonsense';
      final result = await aiService.moderateComment(multipleBadComment);
      expect(result, false);
    });
  });
}
