import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  String? docId;
  String? selectedDept;

  List<String> departments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    docId = ModalRoute.of(context)!.settings.arguments as String;

    _load();
    _loadDepartments();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .get();

    setState(() {
      data = doc.data();
      loading = false;
      selectedDept = data?['departmentName'];
    });
  }

  Future<void> _loadDepartments() async {
    final snap =
        await FirebaseFirestore.instance.collection('departments').get();

    setState(() {
      departments = snap.docs.map((e) => e['name'].toString()).toList();
    });
  }

  Future<void> _updateStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({"status": status});

    setState(() => data!['status'] = status);
  }

  Future<void> _updateDepartment(String deptName) async {
    // 🔥 get departmentId first
    final deptSnap = await FirebaseFirestore.instance
        .collection('departments')
        .where('name', isEqualTo: deptName)
        .limit(1)
        .get();

    if (deptSnap.docs.isEmpty) return;

    final deptId = deptSnap.docs.first.id;

    // 🔥 find category using departmentId (NOT name)
    final catSnap = await FirebaseFirestore.instance
        .collection('categories')
        .where('departmentId', isEqualTo: deptId)
        .limit(1)
        .get();

    String newCategory = "Other";
    String newCategoryId = "";

    if (catSnap.docs.isNotEmpty) {
      newCategory = catSnap.docs.first['name'];
      newCategoryId = catSnap.docs.first.id;
    }

    // 🔥 update Firestore properly
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({
      "departmentName": deptName,
      "departmentId": deptId,
      "categoryName": newCategory,
      "categoryId": newCategoryId,
    });

    // 🔥 update UI
    setState(() {
      selectedDept = deptName;
      data!['departmentName'] = deptName;
      data!['categoryName'] = newCategory;
    });
  }

  void _confirmAction(String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$action Complaint"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(action);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPending = data!['status'] == "Pending";
    final isOther = data!['categoryName'] == "Other";

    final images = List<String>.from(data!['beforeImages'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      /// ✅ APPBAR FIX (WHITE ARROW)
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Complaint Detail",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= CATEGORY =================
            _card(
              title: "Category",
              value: data!['categoryName'] ?? '',
            ),

            /// ================= DEPARTMENT =================
            _card(
              title: "Department",
              child: isPending
                  ? DropdownButton<String>(
                      value: selectedDept,
                      isExpanded: true,
                      hint: const Text("Select Department"),
                      items: departments
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _updateDepartment(v);
                      },
                    )
                  : Text(data!['departmentName'] ?? ''),
            ),

            /// ================= PRIORITY =================
            _card(
              title: "Priority",
              value: data!['priority'] ?? '',
              valueColor: _priorityColor(data!['priority']),
            ),

            /// ================= DESCRIPTION =================
            _card(
              title: "Description",
              value: data!['description'] ?? '',
            ),

            /// ================= ADDRESS =================
            _card(
              title: "Address",
              value: data!['location'] ?? '',
            ),

            /// ================= CITIZEN =================
            _card(
              title: "Citizen",
              value: data!['citizenEmail'] ?? '',
            ),

            /// ================= DATE =================
            _card(
              title: "Date",
              value:
                  (data!['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
            ),

            const SizedBox(height: 10),

            /// ================= IMAGES =================
            if (images.isNotEmpty) ...[
              const Text(
                "Images",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(images[i]),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            /// ================= ACTIONS =================
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        if (isOther && selectedDept == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select department first"),
                            ),
                          );
                          return;
                        }
                        _confirmAction("Approved");
                      },
                      child: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _confirmAction("Rejected"),
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

  /// ================= UI CARD =================
  Widget _card({
    required String title,
    String? value,
    Widget? child,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          child ??
              Text(
                value ?? '',
                style: TextStyle(
                  color: valueColor ?? Colors.black,
                  fontSize: 14,
                ),
              ),
        ],
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
