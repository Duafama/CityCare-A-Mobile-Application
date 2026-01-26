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
      // safely convert any Map to Map<String, dynamic>
      complaint = Map<String, dynamic>.from(args);
    } else {
      // fallback if no arguments
      complaint = {
        "title": "Sample Complaint",
        "category": "Sanitation",
        "department": "Sanitation",
        "description": "No description provided.",
        "date": "N/A",
        "priority": "Low",
        "location": "Unknown",
        "images": [],
      };
    }
    setState(() {}); // trigger rebuild after loading complaint
  }

  void handleAction(String action) {
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Complaint $action",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            "The complaint has been $action successfully.",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

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
    // fallback for images
    final List<String> images =
        (complaint['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ["https://via.placeholder.com/150", "https://via.placeholder.com/200"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complaint Detail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: complaint.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    complaint['title'] ?? "Complaint Title",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info rows
                  // Info rows
                  infoRow(
                    "Category",
                    complaint['category']?.toString() ?? "N/A",
                    valueColor: primaryBlue,
                  ),
                  infoRow(
                    "Department",
                    complaint['department']?.toString() ?? "N/A",
                  ),
                  infoRow(
                    "Description",
                    complaint['description']?.toString() ?? "N/A",
                  ),
                  infoRow("Date", complaint['date']?.toString() ?? "N/A"),
                  infoRow(
                    "Priority",
                    complaint['priority']?.toString() ?? "Low",
                    valueColor: priorityColor(
                      complaint['priority']?.toString() ?? "Low",
                    ),
                  ),
                  infoRow(
                    "Location",
                    complaint['location']?.toString() ?? "N/A",
                  ),

                  // Images
                  if (images.isNotEmpty) ...[
                    const Text(
                      "Images",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Approve / Reject buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => handleAction("Approved"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
