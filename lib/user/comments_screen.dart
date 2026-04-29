import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/AIService.dart';
import '../models/comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;
  const CommentsScreen({super.key, required this.complaint});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final AIService _AIService = AIService();
  late final User _currentUser;
  String? _replyingToId;

  final Set<String> _likedComments = {};
  final Map<String, String> _photoCache = {};

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<String?> _getUserPhoto(String userId) async {
    if (_photoCache.containsKey(userId)) return _photoCache[userId];
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final url = doc.data()?['profileImageUrl'] as String?;
      if (url != null && url.isNotEmpty) _photoCache[userId] = url;
      return url;
    } catch (e) {
      return null;
    }
  }

  // Main comment submission
  Future<void> _submitMainComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final bool isSafe = await _AIService.moderateComment(text);
    final complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];
    final userPhoto = await _getUserPhoto(_currentUser.uid);

    final comment = Comment(
      id: FirebaseFirestore.instance.collection('comments').doc().id,
      complaintId: complaintId,
      userId: _currentUser.uid,
      userName: _currentUser.displayName ?? _currentUser.email?.split('@').first ?? 'User',
      text: text,
      createdAt: DateTime.now(),
      isFlagged: !isSafe,
      photoUrl: userPhoto ?? _currentUser.photoURL,
      parentId: null,
      likes: 0,
    );

    await FirebaseFirestore.instance.collection('comments').doc(comment.id).set(comment.toJson());

    if (!isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Comment reported to admin for review.'), backgroundColor: Colors.orange),
      );
    } else {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update({'commentCount': FieldValue.increment(1)});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Comment posted!'), backgroundColor: Colors.green),
      );
    }
    _commentController.clear();
  }

  // Reply submission
  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _replyingToId == null) return;

    final bool isSafe = await _AIService.moderateComment(text);
    final complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];
    final userPhoto = await _getUserPhoto(_currentUser.uid);

    final reply = Comment(
      id: FirebaseFirestore.instance.collection('comments').doc().id,
      complaintId: complaintId,
      userId: _currentUser.uid,
      userName: _currentUser.displayName ?? _currentUser.email?.split('@').first ?? 'User',
      text: text,
      createdAt: DateTime.now(),
      isFlagged: !isSafe,
      photoUrl: userPhoto ?? _currentUser.photoURL,
      parentId: _replyingToId,
      likes: 0,
    );

    await FirebaseFirestore.instance.collection('comments').doc(reply.id).set(reply.toJson());

    if (!isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Reply reported to admin for review.'), backgroundColor: Colors.orange),
      );
    } else {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update({'commentCount': FieldValue.increment(1)});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Reply posted!'), backgroundColor: Colors.green),
      );
    }
    _replyController.clear();
    setState(() => _replyingToId = null);
  }

  Future<void> _toggleLike(String commentId, int currentLikes) async {
    final ref = FirebaseFirestore.instance.collection('comments').doc(commentId);
    if (_likedComments.contains(commentId)) {
      _likedComments.remove(commentId);
      await ref.update({'likes': currentLikes - 1});
    } else {
      _likedComments.add(commentId);
      await ref.update({'likes': currentLikes + 1});
    }
    setState(() {});
  }

  // ✅ NEW: Delete comment/reply with count decrement
  Future<void> _deleteComment(String commentId, String complaintId, bool isFlagged) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Comment', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text('Are you sure you want to delete this comment?', style: GoogleFonts.poppins(color: Colors.white70)),
        backgroundColor: const Color(0xFF1E2B4F),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final commentRef = FirebaseFirestore.instance.collection('comments').doc(commentId);
      final complaintRef = FirebaseFirestore.instance.collection('complaints').doc(complaintId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Only decrement count if comment was publicly visible
        if (!isFlagged) {
          transaction.update(complaintRef, {'commentCount': FieldValue.increment(-1)});
        }
        transaction.delete(commentRef);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment deleted'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A3D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Comments', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('complaintId', isEqualTo: complaintId)
                  .where('isFlagged', isEqualTo: false)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No comments yet. Be the first!', style: GoogleFonts.poppins(color: Colors.white70)),
                  );
                }
                final allComments = snapshot.data!.docs.map((doc) => Comment.fromFirestore(doc)).toList();
                final mainComments = allComments.where((c) => c.parentId == null).toList();
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: mainComments.length,
                  itemBuilder: (context, index) => _buildCommentWithReplies(mainComments[index], allComments),
                );
              },
            ),
          ),

          if (_replyingToId != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF0F1A3D),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(onPressed: _submitReply, icon: const Icon(Icons.send, color: Color(0xFF4A6FFF))),
                  IconButton(onPressed: () => setState(() => _replyingToId = null), icon: const Icon(Icons.close, color: Colors.red)),
                ],
              ),
            ),

          if (_replyingToId == null)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1A3D),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(onPressed: _submitMainComment, icon: const Icon(Icons.send, color: Color(0xFF4A6FFF))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentWithReplies(Comment comment, List<Comment> allComments) {
    final replies = allComments.where((c) => c.parentId == comment.id).toList();
    final isLiked = _likedComments.contains(comment.id);
    final isOwner = _currentUser.uid == comment.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String?>(
          future: _getUserPhoto(comment.userId),
          builder: (context, snapshot) {
            final photoUrl = snapshot.data;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2B4F),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF4A6FFF),
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Text(comment.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(comment.userName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(width: 8),
                            Text(_timeAgo(comment.createdAt), style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(comment.text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, height: 1.4)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleLike(comment.id, comment.likes),
                              child: Row(
                                children: [
                                  Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                                      size: 16, color: isLiked ? Colors.red : Colors.white70),
                                  const SizedBox(width: 6),
                                  Text('${comment.likes}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => setState(() => _replyingToId = comment.id),
                              child: const Row(
                                children: [
                                  Icon(Icons.reply, size: 16, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Text('Reply', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                            // ✅ NEW: Delete button for main comment (owner only)
                            if (isOwner) ...[
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => _deleteComment(comment.id, comment.complaintId, comment.isFlagged),
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                    SizedBox(width: 6),
                                    Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ...replies.map((reply) => _buildReplyTile(reply)).toList(),
      ],
    );
  }

  Widget _buildReplyTile(Comment reply) {
    final isLiked = _likedComments.contains(reply.id);
    final isOwner = _currentUser.uid == reply.userId;

    return FutureBuilder<String?>(
      future: _getUserPhoto(reply.userId),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(left: 50),
          decoration: BoxDecoration(
            color: const Color(0xFF15243B),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4A6FFF),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(reply.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(reply.userName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 8),
                        Text(_timeAgo(reply.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(reply.text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, height: 1.4)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLike(reply.id, reply.likes),
                          child: Row(
                            children: [
                              Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 14, color: isLiked ? Colors.red : Colors.white70),
                              const SizedBox(width: 6),
                              Text('${reply.likes}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // ✅ NEW: Delete button for reply (owner only)
                        if (isOwner)
                          GestureDetector(
                            onTap: () => _deleteComment(reply.id, reply.complaintId, reply.isFlagged),
                            child: const Row(
                              children: [
                                Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                SizedBox(width: 6),
                                Text('Delete', style: TextStyle(color: Colors.red, fontSize: 11)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}