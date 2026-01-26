import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_screen.dart'; // Add this line at the top
import 'submit_screen.dart'; // Add this at the top
import 'comments_screen.dart'; // Add this line
import 'my_complaints_screen.dart'; // Add this import
import 'profile.dart';
import 'chatbot.dart'; // अगर chatbot भी access करना है
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  String _selectedFilter = 'All';
  int _notificationCount = 3; // Number of notifications

  final List<String> _filters = ['All', 'Pending', 'In-Progress', 'Resolved'];

  // Complaint Data
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '1',
      'userName': 'Maryam',
      'userInitial': 'M',
      'category': 'Broken Streetlight',
      'location': '123 Main street, Udaipur',
      'time': '4 hours ago',
      'status': 'Pending',
      'description':
          'A streetlight near 123 Main Street is broken for 4 days now and is not working at nighttime. Last night there was an accident due to poor visibility.',
      'images': [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1518495978945-83d413a61108?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'likes': 24,
      'comments': 8,
      'isLiked': false,
    },
    {
      'id': '2',
      'userName': 'Ahmed Raza',
      'userInitial': 'A',
      'category': 'Garbage Pile Up',
      'location': 'Gulberg, Lahore',
      'time': '6 hours ago',
      'status': 'In-Progress',
      'description':
          'Huge pile of garbage near Main Market Gulberg that hasn\'t been collected for 3 days. It\'s causing bad smell and health hazards for residents.',
      'images': [
        'https://images.unsplash.com/photo-1558640476-437a2e9b7a2f?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'likes': 42,
      'comments': 12,
      'isLiked': true,
    },
    {
      'id': '3',
      'userName': 'Sara Khan',
      'userInitial': 'S',
      'category': 'Water Leakage',
      'location': 'DHA Phase 5',
      'time': '1 day ago',
      'status': 'Resolved',
      'description':
          'Major water leakage near House #45 Street 7. Water is being wasted and road is getting damaged due to continuous flow.',
      'images': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1563201516-9ea3c4c4fe30?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'likes': 18,
      'comments': 5,
      'isLiked': false,
    },
    {
      'id': '4',
      'userName': 'Ali Hassan',
      'userInitial': 'A',
      'category': 'Potholes',
      'location': 'Model Town',
      'time': '2 days ago',
      'status': 'Pending',
      'description':
          'Multiple large potholes on Main Boulevard causing traffic accidents daily. Need immediate repair before more accidents happen.',
      'images': [
        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'likes': 56,
      'comments': 18,
      'isLiked': false,
    },
  ];

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
        actions: [
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                onPressed: () {
                  _goToNotifications();
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
          // Quick Action Button
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
                  _goToSubmitComplaint();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6FFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Public Feed Header
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
                    color: const Color(0xFF0F1A3D),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips - FIXED FOR OVERFLOW
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
                                color: isSelected ? Colors.white : const Color(0xFF0F1A3D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4A6FFF),
                          backgroundColor: Colors.grey[100],
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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

          // Complaints Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 70),
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                
                // Filter logic
                if (_selectedFilter != 'All' && complaint['status'] != _selectedFilter) {
                  return const SizedBox.shrink();
                }
                
                return _buildComplaintCard(complaint);
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', 0),
            _buildBottomNavItem(Icons.add_circle_outline, 'Submit', 1),
            _buildBottomNavItem(Icons.list_alt, 'My Complaints', 2),
            _buildBottomNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
        _handleBottomNavTap(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4A6FFF) : Colors.grey[600],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected ? const Color(0xFF4A6FFF) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF4A6FFF),
                  radius: 20,
                  child: Text(
                    complaint['userInitial'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint['userName'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F1A3D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              complaint['location'],
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint['status'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _getStatusColor(complaint['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Complaint Category: ${complaint['category']}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F1A3D),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Images Grid
          if (complaint['images'].isNotEmpty)
            Container(
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: complaint['images'].length,
                itemBuilder: (context, imgIndex) {
                  return Container(
                    width: 220,
                    margin: EdgeInsets.only(
                      right: imgIndex < complaint['images'].length - 1 ? 12 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(complaint['images'][imgIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Description
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
                    color: const Color(0xFF0F1A3D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _viewComplaintDetails(complaint);
                  },
                  child: Text(
                    'Read More',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF4A6FFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time and Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      complaint['time'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Like Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          complaint['isLiked'] = !complaint['isLiked'];
                          if (complaint['isLiked']) {
                            complaint['likes']++;
                          } else {
                            complaint['likes']--;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            complaint['isLiked']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: complaint['isLiked'] ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${complaint['likes']}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Comment Button
                    GestureDetector(
                      onTap: () {
                        _showComments(complaint);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.comment_outlined,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${complaint['comments']}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Share Button
                    GestureDetector(
                      onTap: () {
                        _shareComplaint(complaint);
                      },
                      child: const Icon(Icons.share_outlined,
                          color: Colors.grey, size: 20),
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
      case 'Pending':
        return Colors.orange;
      case 'In-Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0: // Home
        // Already on home
        break;
      case 1: // Submit
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SubmitScreen(),
    ),
  );
  break;
      case 2: // My Complaints
        _goToMyComplaints();
        break;
      case 3: // Profile
        _goToProfile();
        break;
    }
  }

  void _goToSubmitComplaint() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SubmitScreen(),
    ),
  );
}

  void _viewComplaintDetails(Map<String, dynamic> complaint) {
    // Navigate to complaint details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: ${complaint['category']}'),
        backgroundColor: const Color(0xFF4A6FFF),
      ),
    );
  }

void _goToMyComplaints() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MyComplaintsScreen(),
    ),
  );
}
//
void _goToChatbot() {
    // Navigate to chatbot screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatbotScreen(),
      ),
    );
  }
  //
  void _goToProfile() {
    // Navigate to profile screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(), // यहाँ change
      ),
    );
  }
void _goToNotifications() {
  // Navigate to notifications screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NotificationScreen(),
    ),
  );
}
void _showComments(Map<String, dynamic> complaint) {
  // Navigate to comments screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CommentsScreen(complaint: complaint),
    ),
  );
}

  void _shareComplaint(Map<String, dynamic> complaint) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared: ${complaint['category']}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}