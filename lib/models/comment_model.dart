import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String complaintId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final bool isFlagged;
  final String? photoUrl;
  final int likes;
  final String? parentId;
  final String? rootParentId;  // ✅ For nested replies

  Comment({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.isFlagged = false,
    this.photoUrl,
    this.likes = 0,
    this.parentId,
    this.rootParentId,
  });

  Map<String, dynamic> toJson() => {
    'complaintId': complaintId,
    'userId': userId,
    'userName': userName,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
    'isFlagged': isFlagged,
    'photoUrl': photoUrl,
    'likes': likes,
    'parentId': parentId,
    'rootParentId': rootParentId,
  };

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      complaintId: data['complaintId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isFlagged: data['isFlagged'] ?? false,
      photoUrl: data['photoUrl'],
      likes: data['likes'] ?? 0,
      parentId: data['parentId'],
      rootParentId: data['rootParentId'],
    );
  }
}