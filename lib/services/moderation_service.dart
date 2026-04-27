import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:profanity_filter/profanity_filter.dart';
import '../models/reported_comment_model.dart';

class ModerationService {
  late final ProfanityFilter _filter;

  final List<String> _customBadWords = [
    'stupid', 'idiot', 'fool', 'dumb', 'moron', 'loser',
    'shut up', 'nonsense', 'rubbish', 'useless',
    'bakwas', 'nalayak', 'ahmaq', 'bewakoof', 'pagal', 'beghairat',
    'khoti', 'bekaar', 'nalaik', 'ahmak', 'badtameez', 'gustakh',
  ];

  ModerationService() {
    _filter = ProfanityFilter.filterAdditionally(_customBadWords);
  }

  bool isCommentSafe(String comment) {
    return !_filter.hasProfanity(comment);
  }

  Future<void> flagCommentAndSave({
    required String commentId,
    required String commentText,
    required String commenterId,
    String reason = 'profanity',
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final reported = ReportedComment(
      commentId: commentId,
      commentText: commentText,
      commenterId: commenterId,
      reportedBy: currentUser.uid,
      reportedAt: DateTime.now(),
      reason: reason,
    );

    await FirebaseFirestore.instance
        .collection('reportedComments')
        .add(reported.toJson());
  }
}