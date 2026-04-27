import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/moderation_service.dart';
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
  final ModerationService _moderation = ModerationService();
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

  Future<void> _submitComment({String? parentId}) async {
    final text = parentId != null ? _replyController.text.trim() : _commentController.text.trim();
    if (text.isEmpty) return;

    final bool isSafe = _moderation.isCommentSafe(text);
    final complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];

    if (!isSafe) {
      await _moderation.flagCommentAndSave(
        commentId: DateTime.now().millisecondsSinceEpoch.toString(),
        commentText: text,
        commenterId: _currentUser.uid,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Comment reported to admin.'), backgroundColor: Colors.orange),
      );
      if (parentId != null) _replyController.clear();
      else _commentController.clear();
      return;
    }

    // 🔥 NESTED REPLY FIX: rootParentId track karo
    String? rootParentId;
    if (parentId != null) {
      final parentDoc = await FirebaseFirestore.instance.collection('comments').doc(parentId).get();
      final parentData = parentDoc.data();
      rootParentId = parentData?['rootParentId'] ?? parentId;
    }

    final userPhoto = await _getUserPhoto(_currentUser.uid);

    final comment = Comment(
      id: FirebaseFirestore.instance.collection('comments').doc().id,
      complaintId: complaintId,
      userId: _currentUser.uid,
      userName: _currentUser.displayName ?? _currentUser.email?.split('@').first ?? 'User',
      text: text,
      createdAt: DateTime.now(),
      isFlagged: false,
      photoUrl: userPhoto ?? _currentUser.photoURL,
      parentId: parentId,
      rootParentId: rootParentId,
      likes: 0,
    );

    await FirebaseFirestore.instance.collection('comments').doc(comment.id).set(comment.toJson());

    if (parentId != null) {
      _replyController.clear();
      setState(() => _replyingToId = null);
    } else {
      _commentController.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Comment posted!'), backgroundColor: Colors.green),
    );
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1A3D), Color(0xFF1E2B4F), Color(0xFF2A3860)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('complaintId', isEqualTo: complaintId)
                    .where('parentId', isEqualTo: null)
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
                  final comments = snapshot.data!.docs.map((doc) => Comment.fromFirestore(doc)).toList();
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: comments.length,
                    itemBuilder: (context, index) => _buildCommentTree(comments[index]),
                  );
                },
              ),
            ),

            // 🔥 REPLY INPUT
            if (_replyingToId != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF0F1A3D),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2B4F),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4A6FFF)),
                        ),
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
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _submitComment(parentId: _replyingToId),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4A6FFF)),
                        child: const Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _replyingToId = null),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.2)),
                        child: const Icon(Icons.close, color: Colors.white70, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

            // 🔥 MAIN INPUT
            if (_replyingToId == null)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A3D),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
                ),
                child: Row(
                  children: [
                    FutureBuilder<String?>(
                      future: _getUserPhoto(_currentUser.uid),
                      builder: (context, snapshot) {
                        final url = snapshot.data;
                        return CircleAvatar(
                          radius: 17,
                          backgroundColor: const Color(0xFF4A6FFF),
                          backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
                          child: (url == null || url.isEmpty)
                              ? Text(_currentUser.displayName?[0]?.toUpperCase() ?? 'U',
                                  style: const TextStyle(color: Colors.white, fontSize: 14))
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3860),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
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
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _submitComment(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF4A6FFF), Color(0xFF5BC0DE)]),
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTree(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentTile(comment),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('comments')
              .where('parentId', isEqualTo: comment.id)
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
            final replies = snapshot.data!.docs.map((doc) => Comment.fromFirestore(doc)).toList();
            return Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Column(
                children: replies.map((reply) => _buildCommentTile(reply, isReply: true)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment, {bool isReply = false}) {
    final isLiked = _likedComments.contains(comment.id);

    return FutureBuilder<String?>(
      future: _getUserPhoto(comment.userId),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isReply ? const Color(0xFF15243B) : const Color(0xFF1E2B4F),
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