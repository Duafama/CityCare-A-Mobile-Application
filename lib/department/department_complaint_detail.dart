import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/complaint.dart';
import '../models/TimelineEvent.dart';
import '../providers/department_provider.dart';
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
      // fallback: passed as plain complaintId string
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

  /// Timeline dot color matches status
  Color _timelineColor(String status) {
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
              /// TITLE
              Text(
                complaint!.categoryName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 16),

              /// STATUS + PRIORITY
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(complaint!.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      complaint!.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _priorityColor(complaint!.priority),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      complaint!.priority,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// INFO ROWS
              _infoRow("Location", complaint!.location),
              _infoRow("Description", complaint!.description),
              _infoRow(
                "Submitted",
                complaint!.createdAt != null
                    ? _formatDate(complaint!.createdAt!)
                    : "N/A",
              ),
              _infoRow("Citizen", complaint!.citizenEmail),

              const SizedBox(height: 20),

              /// BEFORE IMAGES
              if (complaint!.beforeImages.isNotEmpty) ...[
                const Text(
                  "Complaint Photos",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: complaint!.beforeImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          complaint!.beforeImages[index],
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              /// AFTER IMAGES (resolution proof)
              if (complaint!.afterImages.isNotEmpty) ...[
                const Text(
                  "Resolution Proof",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: complaint!.afterImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          complaint!.afterImages[index],
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              /// ACTIONS
              if (complaint!.status == "Approved" ||
                  complaint!.status == "InProgress") ...[
                const Text(
                  "Actions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),

                const SizedBox(height: 10),

                if (complaint!.status == "Approved")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isActionLoading
                          ? null
                          : () async {
                              setState(() => isActionLoading = true);
                              try {
                                await DepartmentComplaintService()
                                    .markInProgress(
                                  complaint!.complaintId,
                                  complaint!.citizenId,
                                );
                                setState(() {
                                  complaint!.status = "InProgress";
                                  isActionLoading = false;
                                });
                                await _refreshTimeline();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Status updated to In Progress"),
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
                  ),

                if (complaint!.status == "InProgress")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          DepartmentRoutes.uploadProof,
                          arguments: complaint,
                        ).then((_) {
                          // Refresh after returning from upload screen
                          _loadComplaint();
                        });
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
                  ),
              ],

              if (complaint!.status == "Resolved")
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.teal),
                      SizedBox(width: 10),
                      Text(
                        "This complaint has been resolved",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              /// TIMELINE SECTION
              const Text(
                "Activity Timeline",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 12),

              timeline.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "No activity yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timeline.length,
                        itemBuilder: (context, index) {
                          final event = timeline[index];
                          final isLast = index == timeline.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Dot + line
                                Column(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _timelineColor(event.status),
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(width: 14),

                                /// Content
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(bottom: isLast ? 0 : 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.status,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _timelineColor(event.status),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          event.message,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(event.timestamp),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}