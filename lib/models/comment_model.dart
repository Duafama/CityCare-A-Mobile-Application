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
  final String? parentId;  // null = main comment, not null = reply to main comment

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
  });

  Map<String, dynamic> toJson() {
  final map = <String, dynamic>{
    'complaintId': complaintId,
    'userId': userId,
    'userName': userName,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
    'isFlagged': isFlagged,
    'photoUrl': photoUrl,
    'likes': likes,
    // ❌ 'parentId': parentId,  // Yeh hata do
  };

  // ✅ Sirf tab add karo jab reply ho
  if (parentId != null) {
    map['parentId'] = parentId;
  }

  return map;
}

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
    );
  }
}