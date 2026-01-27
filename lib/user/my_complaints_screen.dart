import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'complaint_detail_screen.dart';
import 'edit_complaint_screen.dart';
import 'delete_confirmation_dialog.dart';
import 'submit_screen.dart';
import 'profile.dart';
import 'dashboard_screen.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

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
      body: const MyComplaintsContent(),
      
      // SAME navigation as dashboard
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Always show My Complaints selected
        onTap: (index) {
          _handleNavigation(index, context);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0F1A3D),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class MyComplaintsContent extends StatefulWidget {
  const MyComplaintsContent({super.key});

  @override
  State<MyComplaintsContent> createState() => _MyComplaintsContentState();
}

class _MyComplaintsContentState extends State<MyComplaintsContent> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Pending', 'Approved', 'In-Progress', 'Resolved'];

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
    {
      'id': '6',
      'category': 'Park Maintenance',
      'location': 'Central Park, Islamabad',
      'date': '1/20/2026',
      'status': 'Approved',
      'description': 'Broken swings and damaged benches in children park.',
      'images': [
        'https://images.unsplash.com/photo-1576201836106-db175c4e4d9c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.green,
    },
    {
      'id': '7',
      'category': 'Street Sign Missing',
      'location': 'Jinnah Road, Faisalabad',
      'date': '1/18/2026',
      'status': 'Approved',
      'description': 'No entry sign missing causing traffic confusion.',
      'images': [
        'https://images.unsplash.com/photo-1581017918605-4da9b5e9906b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.green,
    },
    {
      'id': '8',
      'category': 'Illegal Parking',
      'location': 'Commercial Area, Multan',
      'date': '1/12/2026',
      'status': 'In-Progress',
      'description': 'Vehicles parked on footpath blocking pedestrian way.',
      'images': [
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      ],
      'statusColor': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _userComplaints.length,
            itemBuilder: (context, index) {
              final complaint = _userComplaints[index];
              
              if (_selectedFilter != 'All' && complaint['status'] != _selectedFilter) {
                return const SizedBox.shrink();
              }
              
              return _buildComplaintCard(complaint);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    // Check if complaint status is Pending
    bool isPending = complaint['status'] == 'Pending';
    
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailScreen(complaint: complaint),
                          ),
                        );
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

                // Show Edit and Delete buttons only for Pending complaints
                if (isPending)
                  Row(
                    children: [
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditComplaintScreen(complaint: complaint),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

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

  Future<void> _deleteComplaint(Map<String, dynamic> complaint) async {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        complaintTitle: complaint['category'],
        onConfirm: () {
          setState(() {
            _userComplaints.removeWhere((item) => item['id'] == complaint['id']);
          });
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
}

// Navigation function (same for all screens)
void _handleNavigation(int index, BuildContext context) {
  switch (index) {
    case 0: // Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      break;
    case 1: // Submit
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SubmitScreen()),
      );
      break;
    case 2: // My Complaints
      // Already here
      break;
    case 3: // Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      break;
  }
}