import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/complaint_enums.dart';
import '../../app_routes.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  ComplaintStatus? selectedStatus;
  String? selectedDept;
  String? sortOrder;

  List<String> departments = [];

  final List<Map<String, String>> sortOptions = [
    {"value": "date_new_old", "label": "Date ↓"},
    {"value": "date_old_new", "label": "Date ↑"},
    {"value": "priority_low_high", "label": "Priority ↑"},
    {"value": "priority_high_low", "label": "Priority ↓"},
    {"value": "name_a_z", "label": "A → Z"},
    {"value": "name_z_a", "label": "Z → A"},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is ComplaintStatus) {
      selectedStatus = arg;
    }

    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final snap =
        await FirebaseFirestore.instance.collection('departments').get();

    setState(() {
      departments = snap.docs.map((e) => e['name'].toString()).toList();
    });
  }

  Stream<QuerySnapshot> _stream() {
    if (selectedStatus == null) {
      return FirebaseFirestore.instance.collection('complaints').snapshots();
    }

    return FirebaseFirestore.instance
        .collection('complaints')
        .where('status', isEqualTo: selectedStatus!.value)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          selectedStatus?.value ?? "Complaints",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// ================= FILTER + SORT =================
            Row(
              children: [
                Expanded(child: _box(_deptDropdown())),
                const SizedBox(width: 8),
                Expanded(child: _box(_sortDropdown())),
              ],
            ),

            const SizedBox(height: 12),

            /// ================= LIST =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  /// FILTER
                  var list = docs.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;

                    if (selectedDept != null &&
                        d['departmentName'] != selectedDept) {
                      return false;
                    }
                    return true;
                  }).toList();

                  /// SORT
                  list.sort((a, b) {
                    final x = a.data() as Map<String, dynamic>;
                    final y = b.data() as Map<String, dynamic>;

                    switch (sortOrder) {
                      case "name_a_z":
                        return x['categoryName']
                            .toString()
                            .compareTo(y['categoryName']);

                      case "name_z_a":
                        return y['categoryName']
                            .toString()
                            .compareTo(x['categoryName']);

                      case "priority_high_low":
                        return _p(y['priority']).compareTo(_p(x['priority']));

                      case "priority_low_high":
                        return _p(x['priority']).compareTo(_p(y['priority']));

                      case "date_new_old":
                        return (y['createdAt'] as Timestamp)
                            .compareTo(x['createdAt']);

                      case "date_old_new":
                        return (x['createdAt'] as Timestamp)
                            .compareTo(y['createdAt']);
                    }
                    return 0;
                  });

                  if (list.isEmpty) {
                    return const Center(child: Text("No complaints"));
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final d = list[index].data() as Map<String, dynamic>;
                      final id = list[index].id;

                      return Card(
                        child: ListTile(
                          title: Text(
                            d['categoryName'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['departmentName'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                d['priority'] ?? '',
                                style: TextStyle(
                                  color: _color(d['priority']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          /// ✅ FIXED NAVIGATION (THIS WAS YOUR MAIN BUG)
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.complaintDetail,
                              arguments: id, // 🔥 MUST BE ID
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CLEAN BOX =================
  Widget _box(Widget child) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  /// ================= FILTER =================
  Widget _deptDropdown() {
    return DropdownButton<String>(
      isExpanded: true,
      value: selectedDept,
      hint: const Text("Dept"),
      underline: const SizedBox(),
      items: [
        const DropdownMenuItem(value: null, child: Text("All")),
        ...departments.map((d) => DropdownMenuItem(
              value: d,
              child: Text(d, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: (v) => setState(() => selectedDept = v),
    );
  }

  /// ================= SORT =================
  Widget _sortDropdown() {
    return DropdownButton<String>(
      isExpanded: true,
      value: sortOrder,
      hint: const Text("Sort"),
      underline: const SizedBox(),
      items: sortOptions
          .map((o) => DropdownMenuItem(
                value: o['value'],
                child: Text(o['label']!),
              ))
          .toList(),
      onChanged: (v) => setState(() => sortOrder = v),
    );
  }

  int _p(String p) {
    switch (p) {
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

  Color _color(String p) {
    switch (p) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
