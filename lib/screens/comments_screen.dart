import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentsScreen extends StatelessWidget {
  final Map<String, dynamic> complaint;
  
  const CommentsScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Comments',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1A3D),
              Color(0xFF1E2B4F),
              Color(0xFF2A3860),
            ],
          ),
        ),
        child: Column(
          children: [
            // Comments List starts directly
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _buildInstagramComment(index);
                },
              ),
            ),
            
            // Add Comment Input Only
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1A3D),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4A6FFF)),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'),
                        fit: BoxFit.cover,
                      ),
                    ),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined, 
                                size: 20, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6FFF), Color(0xFF5BC0DE)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A6FFF).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () {},
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

  Widget _buildInstagramComment(int index) {
    // Instagram-like comment data
    final List<Map<String, dynamic>> instaComments = [
      {
        'name': 'aamadmi12',
        'time': '8h',
        'comment': 'This is a serious issue! I saw the same problem yesterday.',
        'likes': 12,
        'replies': 3,
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': false,
      },
      {
        'name': 'sadspicyslurpersubhan',
        'time': '23h',
        'comment': 'Hope it gets resolved soon. Stay strong!',
        'likes': 8,
        'replies': 0,
        'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': true,
      },
      {
        'name': 'areebahussain3201',
        'time': '23h',
        'comment': 'End per Emotional ho Gaye. Ma b dekhty dekhty',
        'likes': 25,
        'replies': 5,
        'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': false,
      },
      {
        'name': 'saibasultana10',
        'time': '6h',
        'comment': 'I\'ve reported similar issues before.',
        'likes': 5,
        'replies': 1,
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': false,
      },
      {
        'name': 'munawar2467',
        'time': '8h',
        'comment': 'The authorities should take immediate action.',
        'likes': 18,
        'replies': 2,
        'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': true,
      },
      {
        'name': 'iqra_mughal_24',
        'time': '22h',
        'comment': 'Congratulations bahii on raising awareness!',
        'likes': 32,
        'replies': 4,
        'avatar': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': false,
      },
      {
        'name': 'citycare_official',
        'time': '2h',
        'comment': 'Has anyone contacted the local council about this?',
        'likes': 7,
        'replies': 0,
        'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': false,
      },
      {
        'name': 'concerned_citizen',
        'time': '5h',
        'comment': 'We need more people to report these issues.',
        'likes': 15,
        'replies': 1,
        'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'isLiked': false,
      },
    ];
    
    final comment = instaComments[index % instaComments.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2B4F),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with blue border
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A6FFF),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    image: DecorationImage(
                      image: NetworkImage(comment['avatar']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Comment Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Time
                    Row(
                      children: [
                        Text(
                          comment['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${comment['time']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    
                    // Comment Text
                    const SizedBox(height: 6),
                    Text(
                      comment['comment'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    
                    // Likes, Replies and Actions
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Like button
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Icon(
                                comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: comment['isLiked'] ? Colors.red : Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${comment['likes']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Reply button
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reply',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        
                        // View replies if any
                        if (comment['replies'] > 0)
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: const Color(0xFF5BC0DE),
                                ),
                                Text(
                                  '${comment['replies']} replies',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF5BC0DE),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
        ],
      ),
    );
  }
}