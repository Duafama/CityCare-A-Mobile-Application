import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final Map<String, dynamic> complaint;
  
  const ComplaintDetailScreen({super.key, required this.complaint});

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
          'Complaint Detail',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Complaint Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F1A3D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Status Timeline with colorful design
                  _buildColorfulTimeline(complaint['status']),
                  
                  const SizedBox(height: 20),
                  
                  // Current Status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: complaint['statusColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: complaint['statusColor'].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStatusIcon(complaint['status']),
                          color: complaint['statusColor'],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Current Status: ${complaint['status']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: complaint['statusColor'],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complaint Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F1A3D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Category
                  _buildDetailRow(
                    'Category:',
                    complaint['category'],
                    Icons.category_outlined,
                  ),
                  const SizedBox(height: 15),
                  
                  // Date
                  _buildDetailRow(
                    'Date Submitted:',
                    complaint['date'],
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 15),
                  
                  // Location
                  _buildDetailRow(
                    'Location:',
                    complaint['location'],
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 15),
                  
                  // Description Header
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, 
                          color: Color(0xFF0F1A3D)),
                      const SizedBox(width: 10),
                      Text(
                        'Description:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F1A3D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Description Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attached Images',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F1A3D),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Images Grid
                  if (complaint['images'].isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: complaint['images'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(complaint['images'][index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported_outlined,
                              color: Colors.grey, size: 40),
                          const SizedBox(height: 10),
                          Text(
                            'No images attached',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
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
    // Define statuses and their colors
    final List<Map<String, dynamic>> statuses = [
      {
        'title': 'Pending',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
        'isActive': true, // Always active as first step
      },
      {
        'title': 'Approved',
        'icon': Icons.check_circle_outline,
        'color': Colors.blue,
        'isActive': currentStatus == 'Approved' || 
                    currentStatus == 'In-Progress' || 
                    currentStatus == 'Resolved',
      },
      {
        'title': 'In-Progress',
        'icon': Icons.build_circle_outlined,
        'color': Colors.purple,
        'isActive': currentStatus == 'In-Progress' || 
                    currentStatus == 'Resolved',
      },
      {
        'title': 'Resolved',
        'icon': Icons.verified_outlined,
        'color': Colors.green,
        'isActive': currentStatus == 'Resolved',
      },
    ];

    return Column(
      children: [
        // Horizontal timeline with circles
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: statuses.map((status) {
              return Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: status['isActive']
                          ? LinearGradient(
                              colors: [
                                status['color'] as Color,
                                status['color'].withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: status['isActive'] ? null : Colors.grey[300],
                      shape: BoxShape.circle,
                      boxShadow: status['isActive'] ? [
                        BoxShadow(
                          color: status['color'].withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      color: status['isActive'] ? Colors.white : Colors.grey[500],
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: status['isActive'] 
                          ? status['color'] as Color 
                          : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        
        // Timeline connectors
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              _buildTimelineConnector(true, Colors.orange),
              const SizedBox(width: 10),
              _buildTimelineConnector(
                statuses[1]['isActive'] as bool, 
                Colors.blue
              ),
              const SizedBox(width: 10),
              _buildTimelineConnector(
                statuses[2]['isActive'] as bool, 
                Colors.purple
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(bool isActive, Color color) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.5),
                  ],
                )
              : null,
          color: isActive ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
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
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F1A3D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_actions;
      case 'Approved':
        return Icons.check_circle_outline;
      case 'In-Progress':
        return Icons.build_circle_outlined;
      case 'Resolved':
        return Icons.verified_outlined;
      default:
        return Icons.info_outline;
    }
  }
}