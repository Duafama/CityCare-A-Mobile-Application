import 'package:flutter/material.dart';
import 'department_routes.dart';

class DepartmentComplaintDetail extends StatefulWidget {
  const DepartmentComplaintDetail({super.key});

  @override
  State<DepartmentComplaintDetail> createState() =>
      _DepartmentComplaintDetailState();
}

class _DepartmentComplaintDetailState extends State<DepartmentComplaintDetail> {
  Map<String, dynamic> complaint = {};

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      complaint = args;
    } else if (args is Map) {
      complaint = Map<String, dynamic>.from(args);
    } else {
      // Fallback default complaint
      complaint = {
        "title": "Water Leakage Issue",
        "location": "Sector 10",
        "description": "Pipe leakage near main road.",
        "date": DateTime(2026, 1, 15),
        "status": "Approved",
        "priority": "High",
        "category": "Sanitation",
        "images": [],
      };
    }
    setState(() {});
  }

  Color priorityColor(String priority) {
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

  Color statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "In Progress":
        return Colors.blue;
      case "Resolved":
        return Colors.teal;
      case "New":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget infoRow(String label, String value, {Color? valueColor}) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final String status = complaint['status']?.toString() ?? "New";
    final List<String> images = (complaint['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Scaffold(
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
      body: complaint.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -------- TITLE --------
                  Text(
                    complaint['title'] ?? "Complaint Title",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// -------- STATUS & PRIORITY BADGES --------
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor(
                            complaint['priority']?.toString() ?? "Low",
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          complaint['priority']?.toString() ?? "Low",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// -------- INFO ROWS --------
                  infoRow(
                    "Category",
                    complaint['category']?.toString() ?? "N/A",
                  ),
                  infoRow(
                    "Location",
                    complaint['location']?.toString() ?? "N/A",
                  ),
                  infoRow(
                    "Description",
                    complaint['description']?.toString() ?? "N/A",
                  ),
                  infoRow(
                    "Date",
                    complaint['date'] != null
                        ? _formatDate(complaint['date'] as DateTime)
                        : "N/A",
                  ),

                  const SizedBox(height: 16),

                  /// -------- IMAGES --------
                  if (images.isNotEmpty) ...[
                    const Text(
                      "Images",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// -------- ACTION BUTTONS --------
                  if (status == "Approved" || status == "In Progress") ...[
                    const Text(
                      "Actions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (status == "Approved")
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              DepartmentRoutes.updateStatus,
                              arguments: complaint,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            "Mark In Progress",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                    if (status == "In Progress") ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              DepartmentRoutes.uploadProof,
                              arguments: complaint,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text(
                            "Upload Resolution Proof",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              DepartmentRoutes.updateStatus,
                              arguments: complaint,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.update),
                          label: const Text(
                            "Update Status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],

                  if (status == "Resolved") ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.teal.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "This complaint has been resolved",
                              style: TextStyle(
                                color: Colors.teal.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}