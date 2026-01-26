import 'package:flutter/material.dart';
import 'comment_detail.dart';

class FlaggedCommentsScreen extends StatelessWidget {
  const FlaggedCommentsScreen({super.key});

  // Updated comments list with post and createdAt fields
  final List<Map<String, String>> comments = const [
    {
      "comment": "Inappropriate comment 1",
      "user": "User1",
      "post": "Garbage Disposal Guidelines",
      "createdAt": "2026-01-20 14:35",
    },
    {
      "comment": "Inappropriate comment 2",
      "user": "User2",
      "post": "Road Maintenance Schedule",
      "createdAt": "2026-01-21 09:10",
    },
  ];

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

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        title: const Text(
          "Flagged Comments",
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

      /// ---------------- Body ----------------
      body: comments.isEmpty
          ? const Center(
              child: Text(
                "No flagged comments",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentDetailScreen(
                          comment: c['comment']!,
                          user: c['user']!,
                          post: c['post']!,
                          createdAt: c['createdAt']!,
                        ),
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
                        /// ---- Comment Icon ----
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.comment, color: primaryBlue),
                        ),
                        const SizedBox(width: 16),

                        /// ---- Comment Info ----
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['comment']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Reported by ${c['user']} on post: ${c['post']}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Created at: ${c['createdAt']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// ---- Actions ----
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () =>
                              showSnackbar("Comment approved", Colors.green),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              showSnackbar("Comment deleted", Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
