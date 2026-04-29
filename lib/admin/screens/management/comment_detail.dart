import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/comment_model.dart';

class CommentDetailScreen extends StatelessWidget {
  final Comment comment;

  const CommentDetailScreen({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0A1F44);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Comment Detail",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= COMMENT CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// COMMENT TEXT
                  Text(
                    comment.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// USER INFO
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Comment made by: ${comment.userName}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// CREATED AT
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Created at: ${_formatDate(comment.createdAt)}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// LIKES
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 18, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        "Likes: ${comment.likes}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= ACTION BUTTONS =================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () =>
                        _confirmAction(context, "approve", comment),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _confirmAction(context, "delete", comment),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CONFIRMATION DIALOG
  static void _confirmAction(
      BuildContext context, String action, Comment comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm ${action[0].toUpperCase()}${action.substring(1)}"),
        content: Text("Are you sure you want to $action this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (action == "approve") {
                await _approveComment(comment);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Comment approved")),
                );
              } else {
                await _deleteComment(comment);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Comment deleted")),
                );
              }

              Navigator.pop(context);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // ✅ APPROVE
  static Future<void> _approveComment(Comment comment) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('comments').doc(comment.id).update({
      'isFlagged': false,
    });

    await firestore.collection('complaints').doc(comment.complaintId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  // ❌ DELETE
  static Future<void> _deleteComment(Comment comment) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.id)
        .delete();
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
