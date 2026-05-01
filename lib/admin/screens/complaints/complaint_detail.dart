import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/notification_service.dart';

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
  List<Map<String, dynamic>> timeline = [];

  final DepartmentComplaintService _service = DepartmentComplaintService();

  final GlobalKey _categoryButtonKey = GlobalKey();

  // Helper function to format time in 12-hour format
  String _formatTime12Hour(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    int hour12 = hour % 12;
    hour12 = hour12 == 0 ? 12 : hour12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

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
    _loadTimeline();
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

  // load timeline
  Future<void> _loadTimeline() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docId)
          .collection('timeline')
          .orderBy('timestamp')
          .get();

      setState(() {
        timeline = snap.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("TIMELINE ERROR: $e");
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
        .where('status', isEqualTo: 'active')
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

    await NotificationService.notifyStatusChange(
      userId: citizenId,
      complaintId: docId!,
      complaintTitle: complaintTitle,
      oldStatus: oldStatus,
      newStatus: status,
    );

    setState(() => data!['status'] = status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to $status and citizen notified'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reload timeline after status update
    _loadTimeline();
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

  void _showCategoryDropdown() {
    if (_categoryButtonKey.currentContext == null) return;

    final RenderBox renderBox =
        _categoryButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final screenSize = MediaQuery.of(context).size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 2,
        position.dx + size.width,
        0,
      ),
      items: categories.map((category) {
        String categoryName = category['name'] as String;
        return PopupMenuItem<String>(
          value: categoryName,
          padding: EdgeInsets.zero,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenSize.width - 48,
              minWidth: 200,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.label, color: Colors.blue.shade600, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      elevation: 8,
      constraints: BoxConstraints(
        maxWidth: screenSize.width - 32,
        maxHeight: screenSize.height - 100,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).then((value) {
      if (value != null) {
        _updateCategory(value);
      }
    });
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

    timeline.sort((a, b) {
      final t1 = (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
      final t2 = (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
      return t1.compareTo(t2);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Complaint Detail",
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Main content with scrolling
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= CATEGORY DROPDOWN =================
                  _card(
                    title: "Category",
                    child: isPending
                        ? PopupMenuButton<String>(
                            key: _categoryButtonKey,
                            offset: const Offset(0, 5),
                            onSelected: (value) {
                              _updateCategory(value);
                            },
                            constraints: BoxConstraints(
                              maxHeight: 400,
                              maxWidth: 300,
                            ),
                            itemBuilder: (context) {
                              return categories.map((category) {
                                String categoryName =
                                    category['name'] as String;
                                return PopupMenuItem<String>(
                                  value: categoryName,
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.label,
                                          color: Colors.blue.shade600,
                                          size: 18),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          categoryName,
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.category,
                                            color: Colors.blue.shade600,
                                            size: 20),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            selectedCategory ??
                                                "Select Category",
                                            style: TextStyle(
                                              color: selectedCategory == null
                                                  ? Colors.grey
                                                  : Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: Colors.grey.shade600, size: 28),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.category,
                                    color: Colors.blue.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data!['categoryName'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

                  _card(
                      title: "Description", value: data!['description'] ?? ''),
                  _card(title: "Address", value: data!['location'] ?? ''),
                  _card(title: "Citizen", value: data!['citizenEmail'] ?? ''),

                  _card(
                    title: "Date",
                    value: (data!['createdAt'] as Timestamp?)
                            ?.toDate()
                            .toString() ??
                        '',
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

                  // ================= FIXED TIMELINE WITH HORIZONTAL SCROLL =================
                  if (timeline.isNotEmpty) ...[
                    const Text(
                      "Timeline",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Wrap in a Container with fixed height and width constraints
                    Container(
                      height: 130,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate if we need scrolling based on content width
                          double totalWidth = timeline.length *
                              130.0; // 100px for card + 30px for line
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Row(
                              children: List.generate(timeline.length, (index) {
                                final event = timeline[index];
                                final status = event['status'] ?? '';

                                DateTime? time;
                                if (event['timestamp'] is Timestamp) {
                                  time = (event['timestamp'] as Timestamp)
                                      .toDate();
                                }

                                final isLast = index == timeline.length - 1;

                                return Row(
                                  children: [
                                    // Timeline item
                                    SizedBox(
                                      width: 100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // ICON CIRCLE
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                _statusColor(status),
                                            child: Icon(
                                              _statusIcon(status),
                                              size: 22,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // STATUS
                                          Text(
                                            status,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // DATE
                                          Text(
                                            time != null
                                                ? "${time.day.toString().padLeft(2, '0')}-"
                                                    "${time.month.toString().padLeft(2, '0')}-"
                                                    "${time.year}"
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          // TIME in 12-hour format
                                          Text(
                                            time != null
                                                ? _formatTime12Hour(time)
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // CONNECTING LINE
                                    if (!isLast)
                                      Container(
                                        width: 30,
                                        height: 2,
                                        color: Colors.grey.shade300,
                                      ),
                                  ],
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ================= FIXED BUTTONS AT BOTTOM =================
          if (isPending)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
                        child: const Text("Approve",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _confirmAction("Rejected"),
                        child: const Text("Reject",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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

IconData _statusIcon(String status) {
  switch (status) {
    case "Pending":
      return Icons.hourglass_empty;
    case "Approved":
      return Icons.check_circle;
    case "InProgress":
      return Icons.build;
    case "In-Progress":
      return Icons.build;
    case "Resolved":
      return Icons.done_all;
    default:
      return Icons.info;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case "Pending":
      return Colors.orange;
    case "Approved":
      return Colors.blue;
    case "InProgress":
      return Colors.grey;
    case "In-Progress":
      return Colors.grey;
    case "Resolved":
      return Colors.green;
    default:
      return Colors.black;
  }
}
