import 'package:flutter_test/flutter_test.dart';
import 'package:city_care/models/comment_model.dart';

void main() {
  group('Comment Model Tests', () {
    test('UT-7-1: toJson() should convert Comment to Map correctly', () {
      final comment = Comment(
        id: 'com1',
        complaintId: 'comp123',
        userId: 'user123',
        userName: 'Test User',
        text: 'Great work by the department',
        createdAt: DateTime.now(),
        isFlagged: false,
        likes: 0,
      );

      final json = comment.toJson();

      expect(json['complaintId'], 'comp123');
      expect(json['userId'], 'user123');
      expect(json['userName'], 'Test User');
      expect(json['text'], 'Great work by the department');
      expect(json['isFlagged'], false);
      expect(json['likes'], 0);
    });

    test('UT-7-2: Comment with parentId (reply) sets parentId correctly', () {
      final reply = Comment(
        id: 'com2',
        complaintId: 'comp123',
        userId: 'user456',
        userName: 'Another User',
        text: 'I agree with you',
        createdAt: DateTime.now(),
        isFlagged: false,
        likes: 0,
        parentId: 'com1',
      );

      final json = reply.toJson();

      expect(json['parentId'], 'com1');
    });

    test('UT-7-3: Flagged comment has isFlagged=true', () {
      final flaggedComment = Comment(
        id: 'com3',
        complaintId: 'comp123',
        userId: 'user789',
        userName: 'Bad User',
        text: 'This is offensive content',
        createdAt: DateTime.now(),
        isFlagged: true,
        likes: 0,
      );

      expect(flaggedComment.isFlagged, true);
    });
  });
}
