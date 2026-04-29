import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/comment_model.dart';
import 'comment_detail.dart'; // 👈 IMPORTANT: make sure this is imported

class FlaggedCommentsScreen extends StatelessWidget {
  const FlaggedCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0A1F44);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Flagged Comments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('isFlagged', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No flagged comments"));
          }

          final comments = snapshot.data!.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final c = comments[index];

              return GestureDetector(
                // 👈 ADDED
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentDetailScreen(comment: c),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.comment, color: primaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "By ${c.userName}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(c.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () =>
                                _showConfirmDialog(context, true, c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _showConfirmDialog(context, false, c),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static void _showConfirmDialog(
      BuildContext context, bool isApprove, Comment comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isApprove ? "Approve Comment" : "Delete Comment"),
        content: Text(isApprove
            ? "Are you sure you want to approve this comment?"
            : "Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                if (isApprove) {
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
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  static Future<void> _approveComment(Comment comment) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('comments').doc(comment.id).update({
      'isFlagged': false,
    });

    await firestore.collection('complaints').doc(comment.complaintId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  static Future<void> _deleteComment(Comment comment) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('comments').doc(comment.id).delete();
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
