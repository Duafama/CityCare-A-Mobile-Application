import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';
import '../models/complaint_enums.dart';
import '../models/priority_enums.dart';
import '../models/TimelineEvent.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1. Add Complaint
  Future<void> addComplaint(Complaint complaint) async {
    try {
      String id = _firestore.collection('complaints').doc().id;

      complaint.complaintId = id;
      complaint.createdAt = DateTime.now();
      complaint.updatedAt = DateTime.now();
      complaint.status = "Pending";
      complaint.commentCount = 0;
      complaint.upvoteCount = 0;

      await _firestore.collection('complaints').doc(id).set({
        ...complaint.toMap(),
        "beforeImages": complaint.beforeImages,
        "afterImages": [],
      });

      // Add initial timeline event
      await _addTimelineEvent(
        complaintId: id,
        status: "Pending",
        message: "Complaint submitted successfully",
      );
    } catch (e) {
      throw Exception("Error adding complaint: $e");
    }
  }

  /// Helper method to add timeline event
  Future<void> _addTimelineEvent({
    required String complaintId,
    required String status,
    required String message,
  }) async {
    try {
      final timelineEvent = TimelineEvent(
        status: status,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .collection('timeline')
          .add(timelineEvent.toMap());
    } catch (e) {
      print("Error adding timeline event: $e");
    }
  }

  /// 2. Get all complaints
  Future<List<Complaint>> getComplaints() async {
    final snapshot = await _firestore.collection('complaints').get();
    return snapshot.docs
        .map((doc) => Complaint.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// 3. Get complaints by citizen
  Future<List<Complaint>> getComplaintsByUser(String citizenId) async {
    final snapshot = await _firestore
        .collection('complaints')
        .where('citizenId', isEqualTo: citizenId)
        .get();

    return snapshot.docs
        .map((doc) => Complaint.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// 4. Get complaints stream with filters
  Stream<QuerySnapshot> getComplaintsStream({ComplaintStatus? status}) {
    if (status == null) {
      return _firestore.collection('complaints').snapshots();
    }
    return _firestore
        .collection('complaints')
        .where('status', isEqualTo: status.value)
        .snapshots();
  }

  /// 5. Get single complaint by ID
  Future<Map<String, dynamic>?> getComplaintById(String complaintId) async {
    try {
      final doc =
          await _firestore.collection('complaints').doc(complaintId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception("Error loading complaint: $e");
    }
  }

  /// 6. Load timeline for a complaint - FIXED to return List<TimelineEvent>
  Future<List<TimelineEvent>> loadTimeline(String complaintId) async {
    try {
      final snap = await _firestore
          .collection('complaints')
          .doc(complaintId)
          .collection('timeline')
          .orderBy('timestamp', descending: false)
          .get();

      return snap.docs.map((doc) => TimelineEvent.fromMap(doc.data())).toList();
    } catch (e) {
      print("TIMELINE ERROR: $e");
      return [];
    }
  }

  /// 7. Load all departments
  Future<List<String>> loadDepartments() async {
    final snap = await _firestore.collection('departments').get();
    return snap.docs.map((e) => e['name'].toString()).toList();
  }

  /// 8. Load active categories
  Future<List<Map<String, dynamic>>> loadActiveCategories() async {
    final snap = await _firestore
        .collection('categories')
        .where('status', isEqualTo: 'active')
        .get();

    return snap.docs.where((doc) => doc['name'] != "Other").map((doc) {
      return {
        "id": doc.id,
        "name": doc['name'],
        "departmentId": doc['departmentId'],
      };
    }).toList();
  }

  /// 9. Approve complaint with category and department
  Future<void> approveComplaint({
    required String complaintId,
    required String status,
    required String categoryName,
    required String categoryId,
    required String departmentId,
    required String departmentName,
  }) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      "status": status,
      "categoryId": categoryId,
      "categoryName": categoryName,
      "departmentId": departmentId,
      "departmentName": departmentName,
      "updatedAt": DateTime.now(),
    });

    // Add timeline event for approval
    await _addTimelineEvent(
      complaintId: complaintId,
      status: status,
      message: "Complaint approved and assigned to $departmentName",
    );
  }

  /// 10. Reject complaint (no department saved)
  Future<void> rejectComplaint({
    required String complaintId,
    required String status,
  }) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      "status": status,
      "departmentId": null,
      "departmentName": null,
      "updatedAt": DateTime.now(),
    });

    // Add timeline event for rejection
    await _addTimelineEvent(
      complaintId: complaintId,
      status: status,
      message: "Complaint rejected",
    );
  }

  /// 11. Update complaint status (InProgress, Resolved)
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      "status": status,
      "updatedAt": DateTime.now(),
    });

    // Add timeline event for status change
    String message = status == "InProgress"
        ? "Work started on complaint"
        : "Complaint marked as resolved";

    await _addTimelineEvent(
      complaintId: complaintId,
      status: status,
      message: message,
    );
  }

  /// 12. Update category only (for pending complaints)
  Future<Map<String, dynamic>> updateComplaintCategory({
    required String complaintId,
    required String categoryName,
    required List<Map<String, dynamic>> categories,
  }) async {
    final selected = categories.firstWhere(
      (c) => c['name'] == categoryName,
    );

    final categoryId = selected['id'];
    final deptId = selected['departmentId'];

    final deptDoc =
        await _firestore.collection('departments').doc(deptId).get();

    final deptName = deptDoc.data()?['name'] ?? '';

    await _firestore.collection('complaints').doc(complaintId).update({
      "categoryName": categoryName,
      "categoryId": categoryId,
      "departmentName": deptName,
      "departmentId": deptId,
    });

    return {
      'categoryName': categoryName,
      'categoryId': categoryId,
      'departmentName': deptName,
      'departmentId': deptId,
    };
  }

  /// 13. Get department by ID
  Future<Map<String, dynamic>?> getDepartmentById(String departmentId) async {
    try {
      final doc =
          await _firestore.collection('departments').doc(departmentId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 14. Derive department from category (for backward compatibility)
  Future<Map<String, String?>> deriveDepartmentFromCategory({
    required String? categoryId,
    required String? categoryName,
  }) async {
    String? deptName;
    String? deptId;

    final isOther = categoryName == null || categoryName == "Other";

    if (!isOther && (deptId == null || deptId.isEmpty) && categoryId != null) {
      final catDoc =
          await _firestore.collection('categories').doc(categoryId).get();

      final derivedDeptId = catDoc.data()?['departmentId'];

      if (derivedDeptId != null) {
        final deptDoc =
            await _firestore.collection('departments').doc(derivedDeptId).get();

        deptName = deptDoc.data()?['name'];
        deptId = derivedDeptId;
      }
    }

    return {'deptName': deptName, 'deptId': deptId};
  }

  /// 15. Update status (simple version for backward compatibility)
  Future<void> updateStatus(String complaintId, String status) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      "status": status,
      "updatedAt": DateTime.now(),
    });

    // Add timeline event
    await _addTimelineEvent(
      complaintId: complaintId,
      status: status,
      message: "Complaint status changed to $status",
    );
  }

  /// 16. Delete complaint
  Future<void> deleteComplaint(String complaintId) async {
    // Delete timeline subcollection first
    final timelineSnapshot = await _firestore
        .collection('complaints')
        .doc(complaintId)
        .collection('timeline')
        .get();

    for (var doc in timelineSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the complaint
    await _firestore.collection('complaints').doc(complaintId).delete();
  }

  /// 17. Filter complaints based on criteria
  List<QueryDocumentSnapshot> filterComplaints(
    List<QueryDocumentSnapshot> complaints, {
    String? category,
    String? searchQuery,
  }) {
    var filtered = complaints;

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['categoryName'] == category;
      }).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final categoryName =
            data['categoryName']?.toString().toLowerCase() ?? '';
        final departmentName =
            data['departmentName']?.toString().toLowerCase() ?? '';
        final complaintId = data['complaintId']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';

        return categoryName.contains(query) ||
            departmentName.contains(query) ||
            complaintId.contains(query) ||
            description.contains(query);
      }).toList();
    }

    return filtered;
  }

  /// 18. Sort complaints
  List<QueryDocumentSnapshot> sortComplaints(
    List<QueryDocumentSnapshot> complaints, {
    String? sortOrder,
  }) {
    final sorted = List<QueryDocumentSnapshot>.from(complaints);

    sorted.sort((a, b) {
      final x = a.data() as Map<String, dynamic>;
      final y = b.data() as Map<String, dynamic>;

      switch (sortOrder) {
        case "name_a_z":
          return x['categoryName']
              .toString()
              .toLowerCase()
              .compareTo(y['categoryName'].toString().toLowerCase());

        case "name_z_a":
          return y['categoryName']
              .toString()
              .toLowerCase()
              .compareTo(x['categoryName'].toString().toLowerCase());

        case "priority_high_low":
          return _getPriorityValue(y['priority'])
              .compareTo(_getPriorityValue(x['priority']));

        case "priority_low_high":
          return _getPriorityValue(x['priority'])
              .compareTo(_getPriorityValue(y['priority']));

        case "date_new_old":
          final xDate = x['createdAt'] as Timestamp?;
          final yDate = y['createdAt'] as Timestamp?;
          if (xDate == null && yDate == null) return 0;
          if (xDate == null) return 1;
          if (yDate == null) return -1;
          return yDate.compareTo(xDate);

        case "date_old_new":
          final xDate = x['createdAt'] as Timestamp?;
          final yDate = y['createdAt'] as Timestamp?;
          if (xDate == null && yDate == null) return 0;
          if (xDate == null) return 1;
          if (yDate == null) return -1;
          return xDate.compareTo(yDate);

        default:
          return 0;
      }
    });

    return sorted;
  }

  /// 19. Load categories for filter
  Future<List<String>> loadCategories() async {
    final snap = await _firestore.collection('categories').get();
    return snap.docs.map((e) => e['name'].toString()).toList();
  }

  int _getPriorityValue(String p) {
    switch (p.toLowerCase()) {
      case "low":
        return 1;
      case "medium":
        return 2;
      case "high":
        return 3;
      default:
        return 0;
    }
  }
}
