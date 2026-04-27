import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/departmentComplaintService.dart';

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
  String? selectedCategory;

  List<String> departments = [];
  List<Map<String, dynamic>> categories = [];

  final DepartmentComplaintService _service = DepartmentComplaintService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    docId = ModalRoute.of(context)!.settings.arguments as String;

    _load();
    _loadDepartments();
    _loadCategories();
  }

  // ===================== LOAD =====================
  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .get();

    final complaintData = doc.data();

    String? deptName = complaintData?['departmentName'];

    // 🔥 If missing → derive from category
    if ((deptName == null || deptName.isEmpty) &&
        complaintData?['categoryId'] != null) {
      final catDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(complaintData!['categoryId'])
          .get();

      final deptId = catDoc.data()?['departmentId'];

      if (deptId != null) {
        final deptDoc = await FirebaseFirestore.instance
            .collection('departments')
            .doc(deptId)
            .get();

        deptName = deptDoc.data()?['name'];
      }
    }

    setState(() {
      data = complaintData;
      loading = false;

      selectedCategory = complaintData?['categoryName'];
      selectedDept = deptName;
    });
  }

  // ===================== LOAD DEPARTMENTS =====================
  Future<void> _loadDepartments() async {
    final snap =
        await FirebaseFirestore.instance.collection('departments').get();

    setState(() {
      departments = snap.docs.map((e) => e['name'].toString()).toList();
    });
  }

  // ===================== LOAD ACTIVE CATEGORIES =====================
  Future<void> _loadCategories() async {
    final snap = await FirebaseFirestore.instance
        .collection('categories')
        .where('status', isEqualTo: 'active') // ✅ FIXED
        .get();

    setState(() {
      categories = snap.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc['name'],
          "departmentId": doc['departmentId'],
        };
      }).toList();
    });
  }

  // ===================== UPDATE STATUS =====================
  Future<void> _updateStatus(String status) async {
    await _service.updateComplaintStatus(docId!, status);

    setState(() => data!['status'] = status);
  }

  // ===================== UPDATE CATEGORY (AUTO DEPT) =====================
  Future<void> _updateCategory(String categoryName) async {
    final selected = categories.firstWhere(
      (c) => c['name'] == categoryName,
      orElse: () => {},
    );

    if (selected.isEmpty) return;

    final categoryId = selected['id'];
    final deptId = selected['departmentId'];

    if (deptId == null || deptId.toString().isEmpty) {
      print("❌ Department ID missing in category");
      return;
    }

    final deptDoc = await FirebaseFirestore.instance
        .collection('departments')
        .doc(deptId)
        .get();

    if (!deptDoc.exists) {
      print("❌ Department not found in Firestore");
      return;
    }

    final deptName = deptDoc.data()?['name'] ?? '';

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({
      "categoryName": categoryName,
      "categoryId": categoryId,
      "departmentName": deptName,
      "departmentId": deptId,
    });

    setState(() {
      selectedCategory = categoryName;
      selectedDept = deptName;

      data!['categoryName'] = categoryName;
      data!['departmentName'] = deptName;
    });
  }

  // ===================== CONFIRM ACTION =====================
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

  // ===================== IMAGE VIEW =====================
  void _openImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }

  Widget _imageItem(String url) {
    return GestureDetector(
      onTap: () => _openImage(url),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
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
    final isOther = selectedCategory == "Other";

    final beforeImages = List<String>.from(data!['beforeImages'] ?? []);
    final afterImages = List<String>.from(data!['afterImages'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Complaint Detail",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= CATEGORY DROPDOWN =================
            _card(
              title: "Category",
              child: isPending
                  ? DropdownButton<String>(
                      value:
                          categories.any((c) => c['name'] == selectedCategory)
                              ? selectedCategory
                              : null,
                      isExpanded: true,
                      hint: const Text("Select Category"),
                      items: categories
                          .map<DropdownMenuItem<String>>(
                              (c) => DropdownMenuItem<String>(
                                    value: c['name'] as String,
                                    child: Text(c['name'] as String),
                                  ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _updateCategory(v);
                      },
                    )
                  : Text(data!['categoryName'] ?? ''),
            ),

            // ================= AUTO UPDATED DEPARTMENT =================
            _card(
              title: "Department",
              value: selectedDept ?? '',
            ),

            _card(
              title: "Priority",
              value: data!['priority'] ?? '',
              valueColor: _priorityColor(data!['priority']),
            ),

            _card(title: "Description", value: data!['description'] ?? ''),
            _card(title: "Address", value: data!['location'] ?? ''),
            _card(title: "Citizen", value: data!['citizenEmail'] ?? ''),

            _card(
              title: "Date",
              value:
                  (data!['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
            ),

            const SizedBox(height: 10),

            if (beforeImages.isNotEmpty) ...[
              const Text("Before Images",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: beforeImages.map(_imageItem).toList(),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ================= APPROVE / REJECT =================
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        if (isOther || selectedCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a valid category"),
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
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
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
