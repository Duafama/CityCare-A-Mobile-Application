import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/notification_service.dart'; // ✅ Ye hona chahiye

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
  String? selectedDeptId;
  String? selectedCategory;
  String? selectedCategoryId;

  List<String> departments = [];
  List<Map<String, dynamic>> categories = [];

  final DepartmentComplaintService _service = DepartmentComplaintService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! String) {
      setState(() => loading = false);
      return;
    }

    docId = args;
    _load();
    _loadDepartments();
    _loadCategories();
  }

  // ===================== LOAD =====================
  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docId)
          .get();

      final complaintData = doc.data();

      if (complaintData == null) {
        setState(() => loading = false);
        return;
      }

      String? deptName = complaintData['departmentName'];
      String? deptId = complaintData['departmentId'];
      String? categoryName = complaintData['categoryName'];

      // ✅ HANDLE "OTHER" SAFELY
      final isOther = categoryName == null || categoryName == "Other";

      if (!isOther &&
          (deptId == null || deptId.isEmpty) &&
          complaintData['categoryId'] != null) {
        final catDoc = await FirebaseFirestore.instance
            .collection('categories')
            .doc(complaintData['categoryId'])
            .get();

        final derivedDeptId = catDoc.data()?['departmentId'];

        if (derivedDeptId != null) {
          final deptDoc = await FirebaseFirestore.instance
              .collection('departments')
              .doc(derivedDeptId)
              .get();

          deptName = deptDoc.data()?['name'];
          deptId = derivedDeptId;
        }
      }

      setState(() {
        data = complaintData;

        selectedCategory = categoryName ?? "Other";
        selectedDept = deptName;
        selectedDeptId = deptId;

        loading = false;
      });
    } catch (e) {
      print("LOAD ERROR: $e");
      setState(() => loading = false);
    }
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
      categories = snap.docs.where((doc) => doc['name'] != "Other").map((doc) {
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
    String oldStatus = data!['status'] ?? 'Pending';
    String citizenId = data!['citizenId'];
    String complaintTitle = data!['categoryName'] ?? 'Complaint';

    await _service.updateComplaintStatus(docId!, status);
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({
      "status": status,
      "categoryId": (selectedCategory != null &&
              categories.any((c) => c['name'] == selectedCategory))
          ? categories.firstWhere((c) => c['name'] == selectedCategory)['id']
          : data!['categoryId'],
      "categoryName": selectedCategory ?? data!['categoryName'],
      "departmentId": selectedDeptId ?? data!['departmentId'],
      "departmentName": selectedDept ?? data!['departmentName'],
    });
    // 🔥 SEND NOTIFICATION TO CITIZEN
    await NotificationService.notifyStatusChange(
      userId: citizenId,
      complaintId: docId!,
      complaintTitle: complaintTitle,
      oldStatus: oldStatus,
      newStatus: status,
    );
    setState(() => data!['status'] = status);
    // 🔥 SHOW SNACKBAR CONFIRMATION
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to $status and citizen notified'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ===================== UPDATE CATEGORY (AUTO DEPT) =====================
  Future<void> _updateCategory(String categoryName) async {
    final selected = categories.firstWhere(
      (c) => c['name'] == categoryName,
    );

    final categoryId = selected['id'];
    final deptId = selected['departmentId'];

    final deptDoc = await FirebaseFirestore.instance
        .collection('departments')
        .doc(deptId)
        .get();

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
      selectedCategoryId = categoryId;

      selectedDept = deptName;
      selectedDeptId = deptId;

      data!['categoryName'] = categoryName;
      data!['categoryId'] = categoryId;
      data!['departmentName'] = deptName;
      data!['departmentId'] = deptId;
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

              final isInvalidCategory =
                  selectedCategory == null || selectedCategory == "Other";

              if (isInvalidCategory) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please select a valid category"),
                  ),
                );
                return;
              }

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
    final isResolved = data!['status'] == "Resolved";
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

            if (isResolved && afterImages.isNotEmpty) ...[
              const Text(
                "After Images",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: afterImages.map(_imageItem).toList(),
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
