import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'complaint_detail_screen.dart';
import 'edit_complaint_screen.dart';
import 'delete_confirmation_dialog.dart';
import 'submit_screen.dart';
import 'profile.dart';
import 'dashboard_screen.dart';

// 🔥ADD ENUMS 
enum ComplaintStatus {
  pending,
  approved,
  inProgress,
  resolved,
}

enum FilterOption {
  all,
  pending,
  approved,
  inProgress,
  resolved,
}

// 🔥 Extension for converting enum to string and vice versa
extension ComplaintStatusExtension on ComplaintStatus {
  String get value {
    switch (this) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.approved:
        return 'Approved';
      case ComplaintStatus.inProgress:
        return 'In-Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }

  static ComplaintStatus fromString(String status) {
    switch (status) {
      case 'Pending':
        return ComplaintStatus.pending;
      case 'Approved':
        return ComplaintStatus.approved;
      case 'In-Progress':
        return ComplaintStatus.inProgress;
      case 'Resolved':
        return ComplaintStatus.resolved;
      default:
        return ComplaintStatus.pending;
    }
  }
}

extension FilterOptionExtension on FilterOption {
  String get value {
    switch (this) {
      case FilterOption.all:
        return 'All';
      case FilterOption.pending:
        return 'Pending';
      case FilterOption.approved:
        return 'Approved';
      case FilterOption.inProgress:
        return 'In-Progress';
      case FilterOption.resolved:
        return 'Resolved';
    }
  }

  static FilterOption fromString(String filter) {
    switch (filter) {
      case 'All':
        return FilterOption.all;
      case 'Pending':
        return FilterOption.pending;
      case 'Approved':
        return FilterOption.approved;
      case 'In-Progress':
        return FilterOption.inProgress;
      case 'Resolved':
        return FilterOption.resolved;
      default:
        return FilterOption.all;
    }
  }
}

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
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  // 🔥 Enum use kiya (String ki jagah)
  FilterOption _selectedFilter = FilterOption.all;

  // 🔥 Filters list ab enum se generate ho rahi hai
  List<FilterOption> get _filters => FilterOption.values;

  // 🔥 Helper function to get status color using enum
  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Colors.orange;
      case ComplaintStatus.approved:
        return Colors.green;
      case ComplaintStatus.inProgress:
        return Colors.blue;
      case ComplaintStatus.resolved:
        return Colors.teal;
    }
  }

  // 🔥 Format date from Timestamp
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  // 🔥 Delete complaint
  Future<void> _deleteComplaint(String complaintId, String complaintTitle) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        complaintTitle: complaintTitle,
        onConfirm: () {
          Navigator.pop(context, true);
        },
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('complaints')
            .doc(complaintId)
            .delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$complaintTitle deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting complaint: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(
        child: Text('Please login to view complaints'),
      );
    }

    return Column(
      children: [
        // Filter Section
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
                            filter.value, // 🔥 Enum ki value use ki
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
                            _selectedFilter = filter; // 🔥 Enum assign kiya
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

        // 🔥 Firestore Stream Builder for Complaints
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('complaints')
                .where('citizenId', isEqualTo: _currentUser!.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4A6FFF),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No complaints found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit your first complaint now',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 🔥 Filter complaints based on selected filter (Enum use kiya)
              var complaints = snapshot.data!.docs.where((doc) {
                if (_selectedFilter == FilterOption.all) return true;
                String statusString = doc['status'] ?? 'Pending';
                ComplaintStatus status = ComplaintStatusExtension.fromString(statusString);
                return status == _selectedFilter; // 🔥 Enum comparison
              }).toList();

              if (complaints.isEmpty) {
                return Center(
                  child: Text(
                    'No ${_selectedFilter.value} complaints found', // 🔥 Enum ki value use ki
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  var doc = complaints[index];
                  Map<String, dynamic> complaint = doc.data() as Map<String, dynamic>;
                  complaint['id'] = doc.id;
                  
                  return _buildComplaintCard(complaint);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    // 🔥 Enum use kiya status ke liye
    String statusString = complaint['status'] ?? 'Pending';
    ComplaintStatus status = ComplaintStatusExtension.fromString(statusString);
    bool isPending = status == ComplaintStatus.pending; // 🔥 Enum comparison
    Color statusColor = _getStatusColor(status);
    String firstImage = complaint['beforeImages'] != null && complaint['beforeImages'].isNotEmpty
        ? complaint['beforeImages'][0]
        : '';

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
                        complaint['categoryName'] ?? 'Other',
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.value, // 🔥 Enum ki value use ki
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: statusColor,
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
                        complaint['location'] ?? 'No location',
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
                      _formatDate(complaint['createdAt']),
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

          // 🔥 Image from Cloudinary
          if (firstImage.isNotEmpty)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(firstImage),
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
                            _deleteComplaint(complaint['id'], complaint['categoryName'] ?? 'Complaint');
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
}

void _handleNavigation(int index, BuildContext context) {
  switch (index) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SubmitScreen()),
      );
      break;
    case 2:
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      break;
  }
}