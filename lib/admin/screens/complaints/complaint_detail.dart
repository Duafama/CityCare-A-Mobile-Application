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
    final deptSnap = await FirebaseFirestore.instance
        .collection('departments')
        .where('name', isEqualTo: deptName)
        .limit(1)
        .get();

    if (deptSnap.docs.isEmpty) return;

    final deptId = deptSnap.docs.first.id;

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

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({
      "departmentName": deptName,
      "departmentId": deptId,
      "categoryName": newCategory,
      "categoryId": newCategoryId,
    });

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

  /// 🔥 FULL SCREEN IMAGE VIEW
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
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 IMAGE ITEM
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
    final isOther = data!['categoryName'] == "Other";

    final beforeImages = List<String>.from(data!['beforeImages'] ?? []);
    final afterImages = List<String>.from(data!['afterImages'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      /// ---------------- AppBar ----------------
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
            _card(title: "Category", value: data!['categoryName'] ?? ''),

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

            _card(
              title: "Priority",
              value: data!['priority'] ?? '',
              valueColor: _priorityColor(data!['priority']),
            ),

            _card(
              title: "Description",
              value: data!['description'] ?? '',
            ),

            _card(
              title: "Address",
              value: data!['location'] ?? '',
            ),

            _card(
              title: "Citizen",
              value: data!['citizenEmail'] ?? '',
            ),

            _card(
              title: "Date",
              value:
                  (data!['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
            ),

            const SizedBox(height: 10),

            /// ================= BEFORE IMAGES =================
            if (beforeImages.isNotEmpty) ...[
              const Text(
                "Before Images",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: beforeImages.length,
                  itemBuilder: (_, i) => _imageItem(beforeImages[i]),
                ),
              ),
            ],

            const SizedBox(height: 12),

            /// ================= AFTER IMAGES =================
            if (data!['status'] == "Resolved" && afterImages.isNotEmpty) ...[
              const Text(
                "After Images",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: afterImages.length,
                  itemBuilder: (_, i) => _imageItem(afterImages[i]),
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

  /// ---------------- UI CARD ----------------
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
