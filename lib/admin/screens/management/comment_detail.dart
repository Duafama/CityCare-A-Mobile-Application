import 'package:flutter/material.dart';

class CommentDetailScreen extends StatelessWidget {
  final String comment;
  final String user;
  final String post;
  final String createdAt;

  const CommentDetailScreen({
    super.key,
    required this.comment,
    required this.user,
    required this.post,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0A1F44);

    void showSnackbar(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Comment Detail",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              /// ---- User ----
              Text(
                "Comment by: $user",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text("On post: $post", style: TextStyle(color: Colors.grey[700])),
              Text(
                "Created at: $createdAt",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              /// ---- Comment Text ----
              Text(comment, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),

              /// ---- Actions ----
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        showSnackbar("Comment approved", Colors.green),
                    child: const Text("Approve"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () =>
                        showSnackbar("Comment deleted", Colors.red),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
