import 'package:flutter/material.dart';
import '../../app_routes.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  String? selectedDept;
  String? sortOrder;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final List<String> departments = [
    "Sanitation",
    "Roads",
    "Water Supply",
    "Electricity",
    "Health",
    "Education",
  ];

  final List<Map<String, String>> sortOptions = [
    {"value": "date_new_old", "label": "Date: New → Old"},
    {"value": "date_old_new", "label": "Date: Old → New"},
    {"value": "priority_low_high", "label": "Priority: Low → High"},
    {"value": "priority_high_low", "label": "Priority: High → Low"},
    {"value": "name_a_z", "label": "Name: A → Z"},
    {"value": "name_z_a", "label": "Name: Z → A"},
  ];

  @override
  Widget build(BuildContext context) {
    final String status = ModalRoute.of(context)!.settings.arguments as String;

    final List<Map<String, dynamic>> complaints = List.generate(
      10,
      (index) => {
        "title": "Complaint #$index",
        "status": status,
        "priority": ["Low", "Medium", "High"][index % 3],
        "department": departments[index % departments.length],
        "date": DateTime(2026, 1, 10 + index),
      },
    );

    final filteredComplaints = complaints
        .where((c) => selectedDept == null || selectedDept == c['department'])
        .toList();

    if (sortOrder != null) {
      switch (sortOrder) {
        case "priority_low_high":
          filteredComplaints.sort((a, b) => _priorityValue(a['priority'])
              .compareTo(_priorityValue(b['priority'])));
          break;
        case "priority_high_low":
          filteredComplaints.sort((a, b) => _priorityValue(b['priority'])
              .compareTo(_priorityValue(a['priority'])));
          break;
        case "name_a_z":
          filteredComplaints.sort(
              (a, b) => (a['title'] as String).compareTo(b['title'] as String));
          break;
        case "name_z_a":
          filteredComplaints.sort(
              (a, b) => (b['title'] as String).compareTo(a['title'] as String));
          break;
        case "date_new_old":
          filteredComplaints.sort((a, b) =>
              (b['date'] as DateTime).compareTo(a['date'] as DateTime));
          break;
        case "date_old_new":
          filteredComplaints.sort((a, b) =>
              (a['date'] as DateTime).compareTo(b['date'] as DateTime));
          break;
      }
    }

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(
          "$status Complaints",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildDepartmentFilter()),
                const SizedBox(width: 16),
                Expanded(child: _buildSortDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredComplaints.isEmpty
                  ? Center(
                      child: Text("No complaints found",
                          style: TextStyle(color: Colors.grey[600])),
                    )
                  : ListView.builder(
                      itemCount: filteredComplaints.length,
                      itemBuilder: (context, index) =>
                          _complaintCard(filteredComplaints[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Filter"),
          value: selectedDept,
          items: [
            const DropdownMenuItem(value: null, child: Text("All Departments")),
            ...departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          ],
          onChanged: (val) => setState(() => selectedDept = val),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Sort"),
          value: sortOrder,
          items: sortOptions
              .map((o) =>
                  DropdownMenuItem(value: o['value'], child: Text(o['label']!)))
              .toList(),
          onChanged: (val) => setState(() => sortOrder = val),
        ),
      ),
    );
  }

  Widget _complaintCard(Map<String, dynamic> complaint) {
    final Color priorityColor = _priorityColor(complaint['priority']);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Text(complaint["title"],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(complaint['priority'],
              style:
                  TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
        ),
        trailing: complaint['status'] == "Pending"
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton("Approve", Colors.green, complaint),
                  const SizedBox(width: 8),
                  _actionButton("Reject", Colors.red, complaint),
                ],
              )
            : null,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.complaintDetail,
          arguments: complaint,
        ),
      ),
    );
  }

  Widget _actionButton(
      String text, Color color, Map<String, dynamic> complaint) {
    return ElevatedButton(
      onPressed: () => _confirmAction(
          complaint, text == "Approve" ? "Approved" : "Rejected"),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  void _confirmAction(Map<String, dynamic> complaint, String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              action == "Approved" ? Icons.check_circle : Icons.cancel,
              color: action == "Approved" ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text("Confirm $action",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        content:
            Text("Are you sure you want to mark this complaint as $action?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showActionResult(action);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showActionResult(String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              action == "Approved" ? Icons.check_circle : Icons.cancel,
              color: action == "Approved" ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text("Complaint $action",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        content: Text("The complaint has been $action successfully."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
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

  int _priorityValue(String priority) {
    switch (priority) {
      case "Low":
        return 1;
      case "Medium":
        return 2;
      case "High":
        return 3;
      default:
        return 0;
    }
  }
}
