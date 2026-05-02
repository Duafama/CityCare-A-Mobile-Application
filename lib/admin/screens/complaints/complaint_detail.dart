import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/complaint_service.dart';
import '../../../services/notification_service.dart';
import '../../../models/TimelineEvent.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final ComplaintService _complaintService = ComplaintService();

  Map<String, dynamic>? data;
  bool loading = true;
  bool isUpdating = false;

  String? docId;
  String? selectedDept;
  String? selectedDeptId;
  String? selectedCategory;
  String? selectedCategoryId;

  List<String> departments = [];
  List<Map<String, dynamic>> categories = [];
  List<TimelineEvent> timeline = [];

  final GlobalKey _categoryButtonKey = GlobalKey();

  String _formatTime12Hour(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
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
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _load(),
      _loadTimeline(),
      _loadDepartments(),
      _loadCategories(),
    ]);
  }

  Future<void> _load() async {
    try {
      final complaintData = await _complaintService.getComplaintById(docId!);

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
        final derived = await _complaintService.deriveDepartmentFromCategory(
          categoryId: complaintData['categoryId'],
          categoryName: categoryName,
        );

        deptName = derived['deptName'];
        deptId = derived['deptId'];
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

  Future<void> _loadTimeline() async {
    final loadedTimeline = await _complaintService.loadTimeline(docId!);
    setState(() {
      timeline = loadedTimeline;
    });
  }

  Future<void> _loadDepartments() async {
    final loadedDepartments = await _complaintService.loadDepartments();
    setState(() {
      departments = loadedDepartments;
    });
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await _complaintService.loadActiveCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _updateStatus(String status) async {
    setState(() => isUpdating = true);

    try {
      String oldStatus = data!['status'] ?? 'Pending';
      String citizenId = data!['citizenId'];
      String complaintTitle = data!['categoryName'] ?? 'Complaint';

      if (status == "Approved") {
        // Check if valid category is selected
        final isInvalidCategory = selectedCategory == null ||
            selectedCategory == "Other" ||
            selectedCategory?.isEmpty == true;

        if (isInvalidCategory) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Please select a valid category before approving"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() => isUpdating = false);
          return;
        }

        // Get category details
        final selected = categories.firstWhere(
          (c) => c['name'] == selectedCategory,
        );

        final categoryId = selected['id'];
        final deptId = selected['departmentId'];

        final deptDoc = await _complaintService.getDepartmentById(deptId);
        final deptName = deptDoc?['name'] ?? '';

        // Approve with department
        await _complaintService.approveComplaint(
          complaintId: docId!,
          status: status,
          categoryName: selectedCategory!,
          categoryId: categoryId,
          departmentId: deptId,
          departmentName: deptName,
        );

        setState(() {
          data!['status'] = status;
          data!['categoryName'] = selectedCategory;
          data!['categoryId'] = categoryId;
          data!['departmentId'] = deptId;
          data!['departmentName'] = deptName;
          selectedCategoryId = categoryId;
          selectedDeptId = deptId;
          selectedDept = deptName;
        });
      } else if (status == "Rejected") {
        // Reject without saving department
        await _complaintService.rejectComplaint(
          complaintId: docId!,
          status: status,
        );

        setState(() {
          data!['status'] = status;
          data!['departmentId'] = null;
          data!['departmentName'] = null;
          selectedDept = null;
          selectedDeptId = null;
        });
      } else {
        // For other statuses (InProgress, Resolved) - keep existing data
        await _complaintService.updateComplaintStatus(
          complaintId: docId!,
          status: status,
        );

        setState(() {
          data!['status'] = status;
        });
      }

      // Send notification to citizen
      await NotificationService.notifyStatusChange(
        userId: citizenId,
        complaintId: docId!,
        complaintTitle: complaintTitle,
        oldStatus: oldStatus,
        newStatus: status,
      );

      setState(() => isUpdating = false);

      // Reload timeline to show new events
      await _loadTimeline();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status updated to $status${status == "Approved" ? " with department assigned" : status == "Rejected" ? " - Department removed" : ""}'),
            backgroundColor: status == "Rejected" ? Colors.red : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateOnly(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  Future<void> _updateCategory(String categoryName) async {
    try {
      // Only allow category change when complaint is Pending
      if (data!['status'] != "Pending") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Cannot change category after complaint is processed"),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final result = await _complaintService.updateComplaintCategory(
        complaintId: docId!,
        categoryName: categoryName,
        categories: categories,
      );

      setState(() {
        selectedCategory = result['categoryName'];
        selectedCategoryId = result['categoryId'];
        selectedDept = result['departmentName'];
        selectedDeptId = result['departmentId'];

        if (data != null) {
          data!['categoryName'] = result['categoryName'];
          data!['categoryId'] = result['categoryId'];
          data!['departmentName'] = result['departmentName'];
          data!['departmentId'] = result['departmentId'];
        }
      });

      // DO NOT reload timeline for category change (no timeline event created)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category updated to $categoryName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("ERROR UPDATING CATEGORY: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmAction(String action) {
    // Special validation for Approve action
    if (action == "Approved") {
      final isInvalidCategory = selectedCategory == null ||
          selectedCategory == "Other" ||
          selectedCategory?.isEmpty == true;

      if (isInvalidCategory) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a valid category before approving"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$action Complaint"),
        content: Text(action == "Rejected"
            ? "Are you sure?"
            : "Are you sure you want to $action this complaint?"),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: action == "Rejected" ? Colors.red : Colors.green,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

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

    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A1F44),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Complaint Detail",
              style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text("Complaint not found"),
        ),
      );
    }

    final isPending = data!['status'] == "Pending";
    final isRejected = data!['status'] == "Rejected";
    final isResolved = data!['status'] == "Resolved";
    final isOther = selectedCategory == "Other";

    // Don't show department for rejected or pending complaints
    final showDepartment = !isPending && !isRejected;

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryCard(isPending, isOther),
                  if (showDepartment) ...[
                    _buildInfoCard(
                        "Department", selectedDept ?? 'Not assigned'),
                  ],
                  _buildInfoCard("Priority", data!['priority'] ?? '',
                      valueColor: _priorityColor(data!['priority'])),
                  _buildInfoCard("Description", data!['description'] ?? ''),
                  _buildInfoCard("Address", data!['location'] ?? ''),
                  _buildInfoCard("Citizen", data!['citizenEmail'] ?? ''),
                  _buildInfoCard(
                    "Date",
                    _formatDateOnly(
                        (data!['createdAt'] as Timestamp?)?.toDate()),
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
                    const Text("After Images",
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                  if (timeline.isNotEmpty) _buildHorizontalTimeline(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isPending) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(bool isPending, bool isOther) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPending &&
                (selectedCategory == "Other" || selectedCategory == null)
            ? Border.all(color: Colors.orange, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Category",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              if (isPending &&
                  (selectedCategory == "Other" || selectedCategory == null))
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Required",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          isPending
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
                      String categoryName = category['name'] as String;
                      return PopupMenuItem<String>(
                        value: categoryName,
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.label,
                                color: Colors.blue.shade600, size: 18),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.category,
                                  color: Colors.blue.shade600, size: 20),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  selectedCategory ?? "Select Category",
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
              : Row(
                  children: [
                    Icon(Icons.category, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data!['categoryName'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {Color? valueColor}) {
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
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // HORIZONTAL SCROLL TIMELINE
  Widget _buildHorizontalTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Timeline",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 130,
          margin: const EdgeInsets.only(bottom: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Row(
              children: List.generate(timeline.length, (index) {
                final event = timeline[index];
                final status = event.status;
                final time = event.timestamp;
                final isLast = index == timeline.length - 1;

                return Row(
                  children: [
                    // Timeline item
                    SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // ICON CIRCLE
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _statusColor(status),
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
                            "${time.day.toString().padLeft(2, '0')}-"
                            "${time.month.toString().padLeft(2, '0')}-"
                            "${time.year}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // TIME in 12-hour format
                          Text(
                            _formatTime12Hour(time),
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
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
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
                onPressed: isUpdating
                    ? null
                    : () {
                        final isInvalidCategory = selectedCategory == null ||
                            selectedCategory == "Other";
                        if (isInvalidCategory) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please select a valid category before approving"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        _confirmAction("Approved");
                      },
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Approve", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isUpdating ? null : () => _confirmAction("Rejected"),
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Reject", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
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
      case "Rejected":
        return Icons.cancel;
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
      case "Rejected":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
