import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_enums.dart';
import '../models/TimelineEvent.dart';
import 'package:intl/intl.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;
  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final String? _complaintId; // store complaint ID

  _ComplaintDetailScreenState() : _complaintId = null;

  @override
  Widget build(BuildContext context) {
    final String complaintId = widget.complaint['complaintId'] ?? widget.complaint['id'];

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').doc(complaintId).snapshots(),
        builder: (context, complaintSnapshot) {
          if (!complaintSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!complaintSnapshot.data!.exists) {
            return Center(child: Text('Complaint not found', style: GoogleFonts.poppins()));
          }

          final complaintData = complaintSnapshot.data!.data() as Map<String, dynamic>;
          complaintData['id'] = complaintSnapshot.data!.id;

          final statusString = complaintData['status'] ?? 'Pending';
          final ComplaintStatus status = ComplaintStatusExtension.fromString(statusString);
          final Color statusColor = _getStatusColor(status);
          final categoryName = complaintData['categoryName'] ?? 'Other';
          final location = complaintData['location'] ?? 'No location';
          final description = complaintData['description'] ?? 'No description';
          final date = _formatDate(complaintData['createdAt']);
          List<String> images = [];
          if (complaintData['beforeImages'] != null && complaintData['beforeImages'] is List) {
            images = List<String>.from(complaintData['beforeImages']);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + Timeline Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      Text('Complaint Status', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
                      const SizedBox(height: 20),
                      _buildColorfulTimeline(statusString),
                      const SizedBox(height: 20),
                      // REAL-TIME TIMELINE FROM SUBCOLLECTION
                      _buildRealtimeTimeline(complaintId),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
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
    itemBuilder: (context, index) => GestureDetector(
      onTap: () => _showFullScreenImage(context, images, index),
      child: Hero(
        tag: 'image_$index',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(images[index]), fit: BoxFit.cover),
          ),
        ),
      ),
    ),
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
          );
        },
      ),
    );
  }

  // Real-time timeline subcollection listener
  Widget _buildRealtimeTimeline(String complaintId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .collection('timeline')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No timeline events yet.', style: GoogleFonts.poppins(color: Colors.grey));
        }
        final events = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TimelineEvent(
            status: data['status'] ?? '',
            message: data['message'] ?? '',
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Timeline', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F1A3D))),
            const SizedBox(height: 12),
            ...events.map((event) => _buildTimelineItem(event)),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem(TimelineEvent event) {
    Color getColor(String status) {
      switch (status) {
        case 'Pending': return Colors.orange;
        case 'Approved': return Colors.green;
        case 'InProgress': return Colors.blue;
        case 'Resolved': return Colors.teal;
        default: return Colors.grey;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10, height: 10, margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: getColor(event.status), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.status, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: getColor(event.status))),
                if (event.message.isNotEmpty) Text(event.message, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                Text(DateFormat('dd MMM yyyy, hh:mm a').format(event.timestamp), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulTimeline(String currentStatus) {
    final statuses = [
      {'title': 'Pending', 'icon': Icons.pending_actions, 'color': Colors.orange, 'isActive': true},
      {'title': 'Approved', 'icon': Icons.check_circle_outline, 'color': Colors.blue,
       'isActive': currentStatus == 'Approved' || currentStatus == 'InProgress' || currentStatus == 'Resolved'},
      {'title': 'InProgress', 'icon': Icons.build_circle_outlined, 'color': Colors.purple,
       'isActive': currentStatus == 'InProgress' || currentStatus == 'Resolved'},
      {'title': 'Resolved', 'icon': Icons.verified_outlined, 'color': Colors.green, 'isActive': currentStatus == 'Resolved'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((s) {
        return Column(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: (s['isActive'] as bool) ? LinearGradient(colors: [s['color'] as Color, (s['color'] as Color).withOpacity(0.8)]) : null,
                color: (s['isActive'] as bool) ? null : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(s['icon'] as IconData, color: (s['isActive'] as bool) ? Colors.white : Colors.grey[500], size: 24),
            ),
            const SizedBox(height: 8),
            Text(s['title'] as String, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: (s['isActive'] as bool) ? s['color'] as Color : Colors.grey[600])),
          ],
        );
      }).toList(),
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
      case 'InProgress': return Icons.build_circle_outlined;
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
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }
  void _showFullScreenImage(BuildContext context, List<String> images, int initialIndex) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(images[initialIndex]),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}
}