import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedIndex = 0;

  // Dummy complaints data
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '1',
      'userName': 'Ahmed Raza',
      'userImage': '👨‍💼',
      'location': 'Gulberg, Lahore',
      'time': '2 hours ago',
      'title': 'Garbage Pile Up',
      'description':
          'There is a huge pile of garbage near Main Market Gulberg that hasn\'t been collected for 3 days. It\'s causing bad smell and health hazards.',
      'imageUrl':
          'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Garbage+Problem',
      'likes': 24,
      'comments': 8,
      'isLiked': false,
      'category': 'Sanitation',
      'status': 'Pending',
      'upvotes': 15,
    },
    {
      'id': '2',
      'userName': 'Sara Khan',
      'userImage': '👩‍💼',
      'location': 'DHA Phase 5',
      'time': '5 hours ago',
      'title': 'Broken Street Light',
      'description':
          'Street light pole number 45 on Street 12 is broken and hanging dangerously. It could fall any time and cause accident.',
      'imageUrl':
          'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Broken+Light',
      'likes': 42,
      'comments': 12,
      'isLiked': true,
      'category': 'Electricity',
      'status': 'In Progress',
      'upvotes': 28,
    },
    {
      'id': '3',
      'userName': 'Ali Hassan',
      'userImage': '👨‍🔧',
      'location': 'Model Town',
      'time': '1 day ago',
      'title': 'Water Leakage Issue',
      'description':
          'Major water leakage near House #45 Street 7. Water is being wasted and road is getting damaged due to continuous flow.',
      'imageUrl':
          'https://via.placeholder.com/400x300/45B7D1/FFFFFF?text=Water+Leakage',
      'likes': 18,
      'comments': 5,
      'isLiked': false,
      'category': 'Water',
      'status': 'Resolved',
      'upvotes': 22,
    },
    {
      'id': '4',
      'userName': 'Fatima Noor',
      'userImage': '👩‍🏫',
      'location': 'Johar Town',
      'time': '2 days ago',
      'title': 'Potholes on Main Road',
      'description':
          'Multiple large potholes on Main Boulevard Johar Town causing traffic accidents daily. Need immediate repair.',
      'imageUrl':
          'https://via.placeholder.com/400x300/96CEB4/FFFFFF?text=Potholes',
      'likes': 56,
      'comments': 18,
      'isLiked': false,
      'category': 'Roads',
      'status': 'Pending',
      'upvotes': 41,
    },
    {
      'id': '5',
      'userName': 'Bilal Ahmed',
      'userImage': '👨‍🌾',
      'location': 'Wapda Town',
      'time': '3 days ago',
      'title': 'Stray Dogs Problem',
      'description':
          'Large number of stray dogs in Block C creating safety issues, especially for children going to school.',
      'imageUrl':
          'https://via.placeholder.com/400x300/FECA57/FFFFFF?text=Stray+Dogs',
      'likes': 31,
      'comments': 9,
      'isLiked': true,
      'category': 'Animals',
      'status': 'In Progress',
      'upvotes': 19,
    },
  ];

  // Bottom Navigation Bar Items
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Explore',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle_outline),
      label: 'Post',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none),
      label: 'Alerts',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Profile',
    ),
  ];

  // Categories for filter
  final List<String> _categories = [
    'All',
    'Sanitation',
    'Electricity',
    'Water',
    'Roads',
    'Animals',
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'City Care',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F1A3D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Color(0xFF0F1A3D)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF0F1A3D)),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stories/Quick Actions
          Container(
            height: 120,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                // Add Complaint Button
                _buildQuickAction(
                  icon: Icons.add_circle,
                  color: const Color(0xFF4A6FFF),
                  label: 'Post Issue',
                  isAdd: true,
                ),
                const SizedBox(width: 12),
                // Quick Action Buttons
                _buildQuickAction(
                  icon: Icons.warning_amber,
                  color: const Color(0xFFFF6B6B),
                  label: 'Emergency',
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  icon: Icons.check_circle,
                  color: const Color(0xFF4ECDC4),
                  label: 'Resolved',
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  icon: Icons.trending_up,
                  color: const Color(0xFFFECA57),
                  label: 'Trending',
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  icon: Icons.location_pin,
                  color: const Color(0xFF45B7D1),
                  label: 'Nearby',
                ),
              ],
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4A6FFF)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4A6FFF)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 1),

          // Complaints Feed
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _complaints.length,
                itemBuilder: (context, index) {
                  final complaint = _complaints[index];

                  // Filter by category
                  if (_selectedCategory != 'All' &&
                      complaint['category'] != _selectedCategory) {
                    return const SizedBox.shrink();
                  }

                  return _buildComplaintCard(complaint);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A6FFF),
        onPressed: () {
          _showPostComplaintDialog();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A6FFF),
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required String label,
    bool isAdd = false,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isAdd ? color.withOpacity(0.1) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isAdd ? color : Colors.grey[200]!,
              width: isAdd ? 2 : 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: isAdd ? 32 : 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          // User Info and More Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  radius: 20,
                  child: Text(
                    complaint['userImage'],
                    style: const TextStyle(fontSize: 20),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F1A3D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: Colors.grey[500], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            complaint['location'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(complaint['status'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(complaint['status']),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              complaint['status'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _getStatusColor(complaint['status']),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {
                    _showPostOptions(complaint);
                  },
                ),
              ],
            ),
          ),

          // Complaint Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(complaint['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Complaint Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6FFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        complaint['category'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF4A6FFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      complaint['time'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  complaint['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
                const SizedBox(height: 16),

                // Stats and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.thumb_up_outlined,
                          count: complaint['likes'],
                          isActive: complaint['isLiked'],
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
                        ),
                        const SizedBox(width: 20),
                        _buildActionButton(
                          icon: Icons.comment_outlined,
                          count: complaint['comments'],
                          onTap: () {
                            _showCommentsDialog(complaint);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildActionButton(
                          icon: Icons.share_outlined,
                          onTap: () {
                            _shareComplaint(complaint);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward,
                            color: Colors.green[600], size: 18),
                        Text(
                          ' ${complaint['upvotes']}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined,
                                  color: Colors.grey[600], size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${(complaint['upvotes'] * 2.5).toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    int? count,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4A6FFF) : Colors.grey[600],
            size: 22,
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isActive ? const Color(0xFF4A6FFF) : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showPostOptions(Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: Text('Report Post', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(complaint);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined,
                    color: Colors.orange),
                title: Text('Mute this user', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${complaint['userName']} muted')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.grey),
                title: Text('Block user', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${complaint['userName']} blocked')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, color: Colors.blue),
                title: Text('Copy link', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostComplaintDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post a Complaint',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _categories
                            .where((cat) => cat != 'All')
                            .map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined),
                              SizedBox(width: 8),
                              Text('Add Photo'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Complaint posted successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Post Complaint',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentsDialog(Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comments (${complaint['comments']})',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Dummy comments count
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        'User $index',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'This is a sample comment about the issue.',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF4A6FFF)),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        setState(() {
                          complaint['comments']++;
                        });
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Complaints', style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['All', 'Pending', 'In Progress', 'Resolved'].map((status) {
                return RadioListTile(
                  title: Text(status, style: GoogleFonts.poppins()),
                  value: status,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _shareComplaint(Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share Complaint',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                      Icons.message_outlined, 'Message', Colors.blue),
                  _buildShareOption(Icons.email_outlined, 'Email', Colors.red),
                  _buildShareOption(
                      Icons.copy_outlined, 'Copy Link', Colors.green),
                  _buildShareOption(Icons.more_horiz, 'More', Colors.grey),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 28,
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showReportDialog(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report Post', style: GoogleFonts.poppins()),
          content: Text(
            'Why are you reporting this post?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post reported successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Report',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
