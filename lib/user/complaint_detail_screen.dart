import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_enums.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  late Map<String, dynamic> _freshComplaint;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFreshData();
  }

  Future<void> _fetchFreshData() async {
    try {
      String complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .get();
      
      if (doc.exists && mounted) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        setState(() {
          _freshComplaint = data;
          _isLoading = false;
        });
      } else if (mounted) {
        // Agar document nahi mila to original complaint use karo
        setState(() {
          _freshComplaint = widget.complaint;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching fresh data: $e');
      if (mounted) {
        setState(() {
          _freshComplaint = widget.complaint;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          title: Text('Complaint Detail', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF4A6FFF))),
      );
    }

    // 🔥 Fresh complaint data use kar rahe hain
    String statusString = _freshComplaint['status'] ?? 'Pending';
    ComplaintStatus status = ComplaintStatusExtension.fromString(statusString);
    Color statusColor = _getStatusColor(status);
    
    String categoryName = _freshComplaint['categoryName'] ?? 'Other';
    String location = _freshComplaint['location'] ?? 'No location';
    String description = _freshComplaint['description'] ?? 'No description';
    String date = _formatDate(_freshComplaint['createdAt']);
    
    // Images - beforeImages array se
    List<String> images = [];
    if (_freshComplaint['beforeImages'] != null && _freshComplaint['beforeImages'] is List) {
      images = List<String>.from(_freshComplaint['beforeImages']);
    }

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
          'Complaint Detail',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Timeline Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  Text('Complaint Status', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
                  const SizedBox(height: 20),
                  _buildColorfulTimeline(statusString),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getStatusIcon(statusString), color: statusColor, size: 28),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Current Status: ${status.value}',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complaint Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
                  const SizedBox(height: 20),
                  _buildDetailRow('Category:', categoryName, Icons.category_outlined),
                  const SizedBox(height: 15),
                  _buildDetailRow('Date Submitted:', date, Icons.calendar_today),
                  const SizedBox(height: 15),
                  _buildDetailRow('Location:', location, Icons.location_on_outlined),
                  const SizedBox(height: 15),
                  Row(children: [
                    const Icon(Icons.description_outlined, color: Color(0xFF0F1A3D)),
                    const SizedBox(width: 10),
                    Text('Description:', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F1A3D))),
                  ]),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                    child: Text(description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Images Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attached Images', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
                  const SizedBox(height: 15),
                  if (images.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: NetworkImage(images[index]), fit: BoxFit.cover),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                          const SizedBox(height: 10),
                          Text('No images attached', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                        ],
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

  Widget _buildColorfulTimeline(String currentStatus) {
    final List<Map<String, dynamic>> statuses = [
      {'title': 'Pending', 'icon': Icons.pending_actions, 'color': Colors.orange, 'isActive': true},
      {'title': 'Approved', 'icon': Icons.check_circle_outline, 'color': Colors.blue,
       'isActive': currentStatus == 'Approved' || currentStatus == 'In-Progress' || currentStatus == 'Resolved'},
      {'title': 'In-Progress', 'icon': Icons.build_circle_outlined, 'color': Colors.purple,
       'isActive': currentStatus == 'In-Progress' || currentStatus == 'Resolved'},
      {'title': 'Resolved', 'icon': Icons.verified_outlined, 'color': Colors.green, 'isActive': currentStatus == 'Resolved'},
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: statuses.map((status) {
              return Column(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: status['isActive'] ? LinearGradient(colors: [status['color'] as Color, status['color'].withOpacity(0.8)]) : null,
                      color: status['isActive'] ? null : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(status['icon'] as IconData, color: status['isActive'] ? Colors.white : Colors.grey[500], size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(status['title'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: status['isActive'] ? status['color'] as Color : Colors.grey[600])),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0F1A3D)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F1A3D))),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending': return Icons.pending_actions;
      case 'Approved': return Icons.check_circle_outline;
      case 'In-Progress': return Icons.build_circle_outlined;
      case 'Resolved': return Icons.verified_outlined;
      default: return Icons.info_outline;
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending: return Colors.orange;
      case ComplaintStatus.approved: return Colors.green;
      case ComplaintStatus.inProgress: return Colors.blue;
      case ComplaintStatus.resolved: return Colors.teal;
      case ComplaintStatus.rejected: return Colors.red;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}