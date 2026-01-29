import 'package:flutter/material.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Map<String, dynamic> complaint = {};

  static const Color primaryBlue = Color(0xFF0A1F44);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      complaint = args;
    } else if (args is Map) {
      complaint = Map<String, dynamic>.from(args);
    } else {
      complaint = {
        "title": "Sample Complaint",
        "category": "Sanitation",
        "department": "Sanitation",
        "description": "No description provided.",
        "date": "N/A",
        "priority": "Low",
        "location": "Unknown",
        "status": "Pending",
        "images": [],
      };
    }
  }

  /// ---------------- ACTION DIALOG ----------------
  void handleAction(String action) {
    setState(() {
      complaint['status'] = action;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              action == "Approved" ? Icons.check_circle : Icons.cancel,
              color: action == "Approved" ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Complaint $action",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "The complaint has been $action successfully.",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  /// ---------------- PRIORITY COLOR ----------------
  Color priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// ---------------- INFO ROW ----------------
  Widget infoRow(String label, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (complaint.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String status = complaint['status']?.toString() ?? "Pending";

    final List<String> images = (complaint['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${status[0].toUpperCase()}${status.substring(1)} Complaint",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              complaint['title']?.toString() ?? "Complaint",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// Info
            infoRow("Category", complaint['category']?.toString() ?? "N/A",
                valueColor: primaryBlue),
            infoRow("Department", complaint['department']?.toString() ?? "N/A"),
            infoRow(
                "Description", complaint['description']?.toString() ?? "N/A"),
            infoRow("Date", complaint['date']?.toString() ?? "N/A"),
            infoRow(
              "Priority",
              complaint['priority']?.toString() ?? "Low",
              valueColor:
                  priorityColor(complaint['priority']?.toString() ?? "Low"),
            ),
            infoRow("Location", complaint['location']?.toString() ?? "N/A"),
            infoRow("Status", status,
                valueColor: status == "Approved"
                    ? Colors.green
                    : status == "Rejected"
                        ? Colors.red
                        : Colors.orange),

            const SizedBox(height: 16),

            /// Images
            if (images.isNotEmpty) ...[
              const Text("Images",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          child: const Icon(Icons.image),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// Buttons only if Pending
            if (status.toLowerCase() == "pending") ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => handleAction("Approved"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => handleAction("Rejected"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
