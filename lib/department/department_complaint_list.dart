import 'package:flutter/material.dart';
import 'department_navigation.dart';
import 'department_routes.dart';

class DepartmentComplaintList extends StatefulWidget {
  const DepartmentComplaintList({super.key});

  @override
  State<DepartmentComplaintList> createState() =>
      _DepartmentComplaintListState();
}

class _DepartmentComplaintListState extends State<DepartmentComplaintList> {
  String selectedFilter = "All";
  String? sortOrder;

  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final List<String> filters = [
    "All",
    "New",
    "Approved",
    "In Progress",
    "Resolved",
  ];

  final List<Map<String, String>> sortOptions = [
    {"value": "date_new_old", "label": "Date: New → Old"},
    {"value": "date_old_new", "label": "Date: Old → New"},
    {"value": "priority_low_high", "label": "Priority: Low → High"},
    {"value": "priority_high_low", "label": "Priority: High → Low"},
  ];

  final List<Map<String, dynamic>> allComplaints = [
    {
      "title": "Broken Streetlight",
      "location": "123 Main Street, Udaipur",
      "date": DateTime(2026, 1, 3),
      "status": "Approved",
      "priority": "Medium",
      "description": "Streetlight not working for 2 days",
    },
    {
      "title": "Pothole on Main Street",
      "location": "Lexton Street, XYZ",
      "date": DateTime(2025, 12, 23),
      "status": "Approved",
      "priority": "High",
      "description": "Large pothole causing traffic issues",
    },
    {
      "title": "Water Leakage Issue",
      "location": "Sector 10, Near Market",
      "date": DateTime(2025, 12, 20),
      "status": "In Progress",
      "priority": "High",
      "description": "Pipe leakage near main road",
    },
    {
      "title": "Garbage Not Collected",
      "location": "Park Avenue, Block C",
      "date": DateTime(2026, 1, 5),
      "status": "New",
      "priority": "Medium",
      "description": "Garbage bins not emptied for 3 days",
    },
    {
      "title": "Drainage Problem",
      "location": "Residential Area, Sector 5",
      "date": DateTime(2025, 12, 15),
      "status": "Resolved",
      "priority": "Low",
      "description": "Blocked drainage system",
    },
    {
      "title": "Street Cleaning Required",
      "location": "Market Street, Downtown",
      "date": DateTime(2026, 1, 1),
      "status": "New",
      "priority": "Low",
      "description": "Street needs thorough cleaning",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredComplaints = _getFilteredComplaints();

    return Scaffold(
      backgroundColor: lightGrey,

      /// ---------------- AppBar ----------------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Complaints",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),

      /// ---------------- Drawer ----------------
    //   drawer: departmentDrawer(context),

      /// ---------------- Body ----------------
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- FILTERS ----------------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: filters.map((filter) {
                  final bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: primaryBlue,
                      backgroundColor: lightGrey,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// ---------------- SORT DROPDOWN ----------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  "Sort by:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildSortDropdown()),
              ],
            ),
          ),

          /// ---------------- COUNT ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "${filteredComplaints.length} Complaint${filteredComplaints.length != 1 ? 's' : ''} Found",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// ---------------- COMPLAINT LIST ----------------
          Expanded(
            child: filteredComplaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No complaints found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredComplaints[index];
                      return ComplaintCard(
                        title: complaint['title'],
                        location: complaint['location'],
                        date: _formatDate(complaint['date']),
                        status: complaint['status'],
                        priority: complaint['priority'],
                        priorityColor: _priorityColor(complaint['priority']),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            DepartmentRoutes.complaintDetail,
                            arguments: complaint,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      /// ---------------- Bottom Nav ----------------
      bottomNavigationBar: departmentBottomNav(context, 1),
    );
  }

  List<Map<String, dynamic>> _getFilteredComplaints() {
    var complaints = allComplaints.where((c) {
      if (selectedFilter == "All") return true;
      return c['status'] == selectedFilter;
    }).toList();

    if (sortOrder != null) {
      switch (sortOrder) {
        case "priority_low_high":
          complaints.sort((a, b) =>
              _priorityValue(a['priority']).compareTo(_priorityValue(b['priority'])));
          break;
        case "priority_high_low":
          complaints.sort((a, b) =>
              _priorityValue(b['priority']).compareTo(_priorityValue(a['priority'])));
          break;
        case "date_new_old":
          complaints.sort((a, b) =>
              (b['date'] as DateTime).compareTo(a['date'] as DateTime));
          break;
        case "date_old_new":
          complaints.sort((a, b) =>
              (a['date'] as DateTime).compareTo(b['date'] as DateTime));
          break;
      }
    }

    return complaints;
  }

  Widget _buildSortDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Select sorting"),
          value: sortOrder,
          items: sortOptions
              .map((o) => DropdownMenuItem(
                    value: o['value'],
                    child: Text(o['label']!),
                  ))
              .toList(),
          onChanged: (val) => setState(() => sortOrder = val),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
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

/// ---------------- Complaint Card ----------------
class ComplaintCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String status;
  final String priority;
  final Color priorityColor;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.priority,
    required this.priorityColor,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -------- TITLE + STATUS --------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// -------- LOCATION --------
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// -------- DATE --------
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              /// -------- PRIORITY BADGE --------
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priority,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}