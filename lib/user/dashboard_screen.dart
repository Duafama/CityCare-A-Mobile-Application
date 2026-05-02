import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_screen.dart';
import 'submit_screen.dart';
import 'comments_screen.dart';
import 'my_complaints_screen.dart';
import 'profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'All';
  int _notificationCount = 0;

  // 🔥 UPVOTE TRACKING
  Set<String> _userUpvotedComplaints = {};

  final List<String> _filters = ['All', 'Approved', 'InProgress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
    _loadUserUpvotedComplaints();
  }

  // 🔥 LOAD USER'S UPVOTED COMPLAINTS
  Future<void> _loadUserUpvotedComplaints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final upvotesSnapshot = await FirebaseFirestore.instance
            .collection('userUpvotes')
            .doc(user.uid)
            .collection('upvotes')
            .get();

        setState(() {
          _userUpvotedComplaints =
              upvotesSnapshot.docs.map((doc) => doc.id).toSet();
        });
      }
    } catch (e) {
      print('Error loading upvotes: $e');
    }
  }

  // 🔥 TOGGLE UPVOTE FUNCTION - FIXED (NO setState causing scroll reset)
  Future<void> _toggleUpvote(String complaintId, int currentUpvotes) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login to upvote'),
              backgroundColor: Colors.red),
        );
        return;
      }

      final complaintRef =
          FirebaseFirestore.instance.collection('complaints').doc(complaintId);
      final upvoteRef = FirebaseFirestore.instance
          .collection('userUpvotes')
          .doc(user.uid)
          .collection('upvotes')
          .doc(complaintId);

      if (_userUpvotedComplaints.contains(complaintId)) {
        // 🔥 REMOVE UPVOTE
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(complaintRef, {'upvoteCount': currentUpvotes - 1});
          transaction.delete(upvoteRef);
        });

        // Update local set only
        _userUpvotedComplaints.remove(complaintId);
      } else {
        // 🔥 ADD UPVOTE
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(complaintRef, {'upvoteCount': currentUpvotes + 1});
          transaction.set(upvoteRef, {
            'complaintId': complaintId,
            'userId': user.uid,
            'timestamp': FieldValue.serverTimestamp(),
          });
        });

        // Update local set only
        _userUpvotedComplaints.add(complaintId);
      }

      // 🔥 NO setState here - StreamBuilder will handle UI update automatically
    } catch (e) {
      print('Error toggling upvote: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating upvote'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .where('isRead', isEqualTo: false)
            .get();
        if (mounted) {
          setState(() {
            _notificationCount = snapshot.docs.length;
          });
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  // 🔥 FETCH USER PROFILE IMAGE FROM FIRESTORE
  Future<String?> _getUserProfileImage(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['profileImageUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  // 🔥 FETCH USER NAME FROM FIRESTORE
  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String name = userDoc['name'] ?? '';
        if (name.isNotEmpty) {
          return name;
        }
      }
      return '';
    } catch (e) {
      print('Error fetching user name: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A3D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'CityCare',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _notificationCount.toString(),
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F1A3D),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4A6FFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubmitScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6FFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Submit a New Complaint',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Public Feed',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F1A3D)),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      bool isSelected = _selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              filter,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0F1A3D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4A6FFF),
                          backgroundColor: Colors.grey[100],
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF4A6FFF)));
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No complaints yet',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to submit a complaint',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                var allComplaints = snapshot.data!.docs;

                var filteredComplaints = allComplaints.where((doc) {
                  String status = doc['status'] ?? 'Pending';
                  if (status == 'Pending' || status == 'Rejected') {
                    return false;
                  }
                  if (_selectedFilter != 'All' && status != _selectedFilter) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filteredComplaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_alt_outlined,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter == 'All' ? 'approved' : _selectedFilter} complaints',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  key: const PageStorageKey('dashboard_feed_list'),
                  padding: const EdgeInsets.only(bottom: 70),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    var doc = filteredComplaints[index];
                    Map<String, dynamic> complaint =
                        doc.data() as Map<String, dynamic>;
                    complaint['id'] = doc.id;
                    return _buildComplaintCard(complaint);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          _handleNavigation(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0F1A3D),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Submit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'My Complaints'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SubmitScreen()));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MyComplaintsScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    String status = complaint['status'] ?? 'Pending';
    Color statusColor = _getStatusColor(status);
    String citizenId = complaint['citizenId'] ?? '';
    String timeAgo = _getTimeAgo(complaint['createdAt']);

    // Before images (complaint images)
    List<String> beforeImages = [];
    if (complaint['beforeImages'] != null &&
        complaint['beforeImages'] is List) {
      beforeImages = List<String>.from(complaint['beforeImages']);
    }

    // After images (resolution images - for resolved complaints)
    List<String> afterImages = [];
    if (complaint['afterImages'] != null && complaint['afterImages'] is List) {
      afterImages = List<String>.from(complaint['afterImages']);
    }

    bool isResolved = status == 'Resolved';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 🔥 USER PROFILE IMAGE
                FutureBuilder<String?>(
                  future: _getUserProfileImage(citizenId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(snapshot.data!),
                        child: null,
                      );
                    } else {
                      return CircleAvatar(
                        backgroundColor: const Color(0xFF4A6FFF),
                        radius: 20,
                        child: FutureBuilder<String>(
                          future: _getUserName(citizenId),
                          builder: (context, nameSnapshot) {
                            String displayName = '';
                            String initial = 'U';

                            if (nameSnapshot.hasData &&
                                nameSnapshot.data!.isNotEmpty) {
                              displayName = nameSnapshot.data!;
                              initial = displayName[0].toUpperCase();
                            } else {
                              // Fallback to email if name not found
                              String userEmail =
                                  complaint['citizenEmail'] ?? 'Anonymous';
                              displayName = userEmail.split('@')[0];
                              initial = displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U';
                            }

                            return Text(
                              initial,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 USER NAME - Fetch from Firestore or use email fallback
                      FutureBuilder<String>(
                        future: _getUserName(citizenId),
                        builder: (context, nameSnapshot) {
                          String displayName = '';

                          if (nameSnapshot.hasData &&
                              nameSnapshot.data!.isNotEmpty) {
                            displayName = nameSnapshot.data!;
                          } else {
                            String userEmail =
                                complaint['citizenEmail'] ?? 'Anonymous';
                            displayName = userEmail.split('@')[0];
                          }

                          return Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F1A3D),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              complaint['location'] ?? 'No location',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(status,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Complaint Category: ${complaint['categoryName'] ?? 'Other'}',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F1A3D)),
            ),
          ),
          const SizedBox(height: 12),

          // 🔥 BEFORE IMAGES
          if (beforeImages.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Before Images',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: beforeImages.length,
                    itemBuilder: (context, imgIndex) {
                      double imageWidth = beforeImages.length == 1
                          ? MediaQuery.of(context).size.width - 32
                          : 280;
                      return Container(
                        width: imageWidth,
                        margin: EdgeInsets.only(
                            right: imgIndex < beforeImages.length - 1 ? 12 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(beforeImages[imgIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // 🔥 AFTER IMAGES
          if (isResolved && afterImages.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'After Images (Resolution Proof)',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Resolved',
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: afterImages.length,
                    itemBuilder: (context, imgIndex) {
                      double imageWidth = afterImages.length == 1
                          ? MediaQuery.of(context).size.width - 32
                          : 280;
                      return Container(
                        width: imageWidth,
                        margin: EdgeInsets.only(
                            right: imgIndex < afterImages.length - 1 ? 12 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.green.withOpacity(0.3), width: 2),
                          image: DecorationImage(
                            image: NetworkImage(afterImages[imgIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F1A3D)),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint['description'] ?? 'No description provided',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[700], height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 6),
                    Text(timeAgo,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleUpvote(
                          complaint['id'], complaint['upvoteCount'] ?? 0),
                      child: Row(
                        children: [
                          Icon(
                            _userUpvotedComplaints.contains(complaint['id'])
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                _userUpvotedComplaints.contains(complaint['id'])
                                    ? Colors.red
                                    : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${complaint['upvoteCount'] ?? 0}',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CommentsScreen(complaint: complaint),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.comment_outlined,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${complaint['commentCount'] ?? 0}',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[700]),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.orange;
      case 'In-Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Recently';

    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
