import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedComment {
  final String? id;
  final String commentId;       // original comment ka ID (jo `comments` collection mein save hoga)
  final String commentText;
  final String commenterId;     // jisne comment likha
  final String reportedBy;      // current user jisne flag kiya
  final DateTime reportedAt;
  final String status;          // 'pending', 'approved', 'rejected'
  final String reason;          // e.g., 'profanity'

  ReportedComment({
    this.id,
    required this.commentId,
    required this.commentText,
    required this.commenterId,
    required this.reportedBy,
    required this.reportedAt,
    this.status = 'pending',
    this.reason = 'profanity',
  });

  Map<String, dynamic> toJson() => {
    'commentId': commentId,
    'commentText': commentText,
    'commenterId': commenterId,
    'reportedBy': reportedBy,
    'reportedAt': Timestamp.fromDate(reportedAt),
    'status': status,
    'reason': reason,
  };

  factory ReportedComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportedComment(
      id: doc.id,
      commentId: data['commentId'],
      commentText: data['commentText'],
      commenterId: data['commenterId'],
      reportedBy: data['reportedBy'],
      reportedAt: (data['reportedAt'] as Timestamp).toDate(),
      status: data['status'],
      reason: data['reason'],
    );
  }
}