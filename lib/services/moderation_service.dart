import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:profanity_filter/profanity_filter.dart';
import '../models/reported_comment_model.dart';

class ModerationService {
  late final ProfanityFilter _filter;

  final List<String> _customBadWords = [
    // 🇬🇧 English
  'stupid', 'idiot', 'fool', 'dumb', 'moron', 'loser',
  'shut up', 'nonsense', 'rubbish', 'useless', 'worthless',
  'liar', 'fraud', 'cheat', 'incompetent', 'pathetic',
  'shameless', 'disgrace', 'scum', 'trash', 'criminal',

  // 🇵🇰 Urdu / Roman Urdu — Insults
  'bakwas', 'nalayak', 'ahmaq', 'bewakoof', 'pagal',
  'beghairat', 'bekaar', 'nalaik', 'badtameez', 'gustakh',
  'ghatiya', 'naayhal', 'chawal', 'kamina', 'kameena',
  'lafanga', 'harami', 'haramzaada', 'naali',
  'gadha', 'gadhe', 'ullu', 'suar', 'kutta', 'kutiya',
  'jhootha', 'jhoothi', 'chor', 'dhokebaaz', 'munafiq',
  'dagabaaz', 'besharam', 'behaya', 'zalim', 'jaahil',
  'anparh', 'ganwar', 'badmash', 'awara', 'mawali',
  'goonda', 'nikamma', 'buzdil', 'darpok',
  // 🇵🇰 Additional — Relevant & Moderate
  'jhalli', 'jhalla', 'sasta', 'ghaleez', 'badnaam',
  'badkaar', 'bayghairat', 'be-izzat', 'bayizzat',
  'zillat', 'ruswa', 'dhoka', 'faraib', 'makkar',
  'faraibi', 'makkaar', 'khosar', 'naamard', 'kayar',
  'choor', 'uchaakka', 'thag', 'thagi', 'lootay',
  'tangay', 'phakkar', 'awaargi', 'badchalan',
  'be-adab', 'beadab', 'gustakhi', 'taanay',

  // 🔄 Bypass Variations
  'b3waqoof', 'p@gal', 'stu pid', 'idi0t', 'kam1na',

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