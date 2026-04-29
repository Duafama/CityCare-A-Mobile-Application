import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/complaint.dart';
import '../models/TimelineEvent.dart';

import '../services/departmentComplaintService.dart';
import 'department_routes.dart';

class DepartmentComplaintDetail extends StatefulWidget {
  const DepartmentComplaintDetail({super.key});

  @override
  State<DepartmentComplaintDetail> createState() =>
      _DepartmentComplaintDetailState();
}

class _DepartmentComplaintDetailState
    extends State<DepartmentComplaintDetail> {
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  Complaint? complaint;
  List<TimelineEvent> timeline = [];
  bool isLoading = true;
  bool isActionLoading = false;
  String source = "dashboard";
  String? complaintId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (complaintId != null) return; // already loaded

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      complaintId = args['complaintId'];
      source = args['source'] ?? "dashboard";
    } else if (args is String) {
      complaintId = args;
    }

    if (complaintId != null) {
      _loadComplaint();
    }
  }

  Future<void> _loadComplaint() async {
    try {
      final service = DepartmentComplaintService();

      final fetchedComplaint =
          await service.getComplaintDetails(complaintId!);

      final fetchedTimeline = await service.getTimeline(complaintId!);

      setState(() {
        complaint = fetchedComplaint;
        timeline = fetchedTimeline;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshTimeline() async {
    try {
      final fetchedTimeline =
          await DepartmentComplaintService().getTimeline(complaintId!);
      setState(() {
        timeline = fetchedTimeline;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _handleBack() async {
    if (source == "list") {
      Navigator.pushReplacementNamed(context, DepartmentRoutes.list);
    } else {
      Navigator.pushReplacementNamed(context, DepartmentRoutes.dashboard);
    }
    return false;
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.amber;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "InProgress":
        return Colors.blue;
      case "Resolved":
        return Colors.teal;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),

          const SizedBox(height: 10),

          /// Content
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _priorityChip(String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _priorityColor(priority),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(priority, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _imageList(List<String> images) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _openImageFullScreen(images[index]);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to show image in fullscreen on tap
  void _openImageFullScreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _timelineItem(TimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _statusColor(event.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _statusColor(event.status),
                  ),
                ),
                Text(event.message),
                Text(
                  _formatDate(event.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          title: const Text("Complaint Detail",
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text("Complaint not found.")),
      );
    }

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: lightGrey,

        /// ---------------- AppBar ----------------
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Complaint Detail",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: primaryBlue,
          elevation: 0,
        ),

        /// ---------------- Body ----------------
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER CARD =================
              _sectionCard(
                title: complaint!.categoryName,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statusChip(complaint!.status),
                        const SizedBox(width: 10),
                        _priorityChip(complaint!.priority),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ================= INFO CARD =================
              _sectionCard(
                title: "Complaint Details",
                child: Column(
                  children: [
                    _infoRow("Location", complaint!.location),
                    _infoRow("Description", complaint!.description),
                    _infoRow(
                      "Submitted",
                      complaint!.createdAt != null
                          ? _formatDate(complaint!.createdAt!)
                          : "N/A",
                    ),
                    _infoRow("Citizen", complaint!.citizenEmail),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ================= IMAGES =================
              if (complaint!.beforeImages.isNotEmpty)
                _sectionCard(
                  title: "Complaint Photos",
                  child: _imageList(complaint!.beforeImages),
                ),

              if (complaint!.afterImages.isNotEmpty)
                _sectionCard(
                  title: "Resolution Proof",
                  child: _imageList(complaint!.afterImages),
                ),

              const SizedBox(height: 16),

              /// ================= ACTIONS =================
              if (complaint!.status == "Approved" ||
                  complaint!.status == "InProgress")
                _sectionCard(
                  title: "Actions",
                  child: Column(
                    children: [
                      if (complaint!.status == "Approved")
                        _buildActionButton(),

                      if (complaint!.status == "InProgress")
                        _buildUploadButton(),
                    ],
                  ),
                ),

              if (complaint!.status == "Resolved")
                _resolvedBanner(),

              const SizedBox(height: 16),

              /// ================= TIMELINE =================
              _sectionCard(
                title: "Activity Timeline",
                child: timeline.isEmpty
                    ? const Text(
                        "No activity yet",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        children: timeline.map((event) {
                          return _timelineItem(event);
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildActionButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: isActionLoading
          ? null
          : () async {
              setState(() => isActionLoading = true);
              try {
                // 🔥 GET OLD STATUS AND CITIZEN INFO (JAISA ADMIN MEIN)
                String oldStatus = complaint!.status;
                String citizenId = complaint!.citizenId;
                String complaintTitle = complaint!.categoryName;
                
                await DepartmentComplaintService()
                    .markInProgress(complaint!.complaintId, complaint!.citizenId);
                
                // 🔥 SEND NOTIFICATION TO CITIZEN (JAISA ADMIN MEIN)
                await NotificationService.notifyStatusChange(
                  userId: citizenId,
                  complaintId: complaint!.complaintId,
                  complaintTitle: complaintTitle,
                  oldStatus: oldStatus,
                  newStatus: 'In-Progress',
                );
                
                setState(() {
                  complaint!.status = "InProgress";
                  isActionLoading = false;
                });
                await _refreshTimeline();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Status updated to In Progress & citizen notified"),
                    backgroundColor: Colors.blue,
                  ),
                );
              } catch (e) {
                setState(() => isActionLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: isActionLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.autorenew),
      label: const Text(
        "Mark In Progress",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

 Widget _buildUploadButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () async {
        // 🔥 GET CITIZEN INFO (JAISA ADMIN MEIN)
        String oldStatus = complaint!.status;
        String citizenId = complaint!.citizenId;
        String complaintTitle = complaint!.categoryName;
        String complaintId = complaint!.complaintId;
        
        final result = await Navigator.pushNamed(
          context,
          DepartmentRoutes.uploadProof,
          arguments: complaint,
        );
        
        if (result == true) {
          // Update status to Resolved
          await DepartmentComplaintService()
              .updateComplaintStatus(complaintId, 'Resolved');
          
          // 🔥 SEND NOTIFICATION TO CITIZEN (JAISA ADMIN MEIN)
          await NotificationService.notifyStatusChange(
            userId: citizenId,
            complaintId: complaintId,
            complaintTitle: complaintTitle,
            oldStatus: oldStatus,
            newStatus: 'Resolved',
          );
          
          _loadComplaint();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Complaint resolved & citizen notified'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _loadComplaint();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.upload_file),
      label: const Text(
        "Upload Resolution Proof",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
  Widget _resolvedBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This complaint has been resolved",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}