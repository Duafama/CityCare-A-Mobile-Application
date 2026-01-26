import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'complaint_detail_screen.dart';
import 'edit_complaint_screen.dart';
import 'delete_confirmation_dialog.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  int _selectedTab = 2;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Pending', 'In-Progress', 'Resolved'];

  // Sample user complaints data
  final List<Map<String, dynamic>> _userComplaints = [
    {
      'id': '1',
      'category': 'Broken Streetlight',
      'location': '123 Main street, Udaypur',
      'date': '1/3/2026',
      'status': 'Approved',
      'description': 'A streetlight near 123 Main Street is broken for 4 days now and is not working at nighttime.',
      'images': [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.green,
    },
    {
      'id': '2',
      'category': 'Pothole on Main Street',
      'location': 'Lexton Street, XYZ',
      'date': '12/23/2025',
      'status': 'Pending',
      'description': 'Large pothole causing traffic issues on main street.',
      'images': [
        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.orange,
    },
    {
      'id': '3',
      'category': 'Garbage Pile Up',
      'location': 'Gulberg, Lahore',
      'date': '1/15/2026',
      'status': 'In-Progress',
      'description': 'Huge pile of garbage near Main Market Gulberg.',
      'images': [
        'https://images.unsplash.com/photo-1558640476-437a2e9b7a2f?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.blue,
    },
    {
      'id': '4',
      'category': 'Water Leakage',
      'location': 'DHA Phase 5, Karachi',
      'date': '1/10/2026',
      'status': 'Resolved',
      'description': 'Major water leakage near House #45 Street 7.',
      'images': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.teal,
    },
    {
      'id': '5',
      'category': 'Drainage Issue',
      'location': 'Saddar, Rawalpindi',
      'date': '1/5/2026',
      'status': 'Pending',
      'description': 'Blocked drainage causing water logging.',
      'images': [
        'https://images.unsplash.com/photo-1563201516-9ea3c4c4fe30?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A3D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Complaints',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F1A3D),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      bool isSelected = _selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

          // Complaints List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _userComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _userComplaints[index];
                
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

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Complaint Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        complaint['category'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F1A3D),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: complaint['statusColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        complaint['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: complaint['statusColor'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, 
                        color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        complaint['location'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, 
                        color: Colors.grey, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      complaint['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Preview Image
          if (complaint['images'].isNotEmpty)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(complaint['images'][0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View Details Button
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6FFF), Color(0xFF5BC0DE)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _viewComplaintDetails(complaint);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Action Buttons
                Row(
                  children: [
                    // Edit Button
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1A3D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, 
                            color: Color(0xFF0F1A3D)),
                        onPressed: () {
                          _editComplaint(complaint);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete Button
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, 
                            color: Colors.red),
                        onPressed: () {
                          _deleteComplaint(complaint);
                        },
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

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _handleBottomNavTap(index),
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

  void _viewComplaintDetails(Map<String, dynamic> complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintDetailScreen(complaint: complaint),
      ),
    );
  }

  void _editComplaint(Map<String, dynamic> complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditComplaintScreen(complaint: complaint),
      ),
    );
  }

  Future<void> _deleteComplaint(Map<String, dynamic> complaint) async {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        complaintTitle: complaint['category'],
        onConfirm: () {
          // Simulate delete action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${complaint['category']} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _selectedTab = index;
    });
    
    if (index != 2) {
      Navigator.pop(context);
    }
  }
}