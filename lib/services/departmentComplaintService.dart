import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';
import '../models/TimelineEvent.dart';


class DepartmentComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===============================
  // 1. GET ASSIGNED COMPLAINTS
  // ===============================
  Future<List<Complaint>> getAssignedComplaints(String departmentId) async {
    final snapshot = await _firestore
        .collection('complaints')
        .where('departmentId', isEqualTo: departmentId)
        .get();

    return snapshot.docs.map((doc) {
      return Complaint.fromMap(doc.id, doc.data());
    }).toList();
  }

  // ===============================
  // 2. GET SINGLE COMPLAINT
  // ===============================
  Future<Complaint?> getComplaintDetails(String complaintId) async {
    final doc =
        await _firestore.collection('complaints').doc(complaintId).get();

    if (doc.exists && doc.data() != null) {
      return Complaint.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // ===============================
  // 3. MARK IN PROGRESS
  // ===============================
  Future<void> markInProgress(String complaintId, String citizenId) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'status': 'InProgress',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _addTimelineEvent(
      complaintId,
      'InProgress',
      'Work has started on this complaint',
    );

    await _sendNotification(
      citizenId,
      'Complaint Update',
      'Your complaint is now in progress',
    );
  }

  // ===============================
  // 4. MARK RESOLVED
  // ===============================
      Future<void> markResolved(
      String complaintId,
      String citizenId,
      String imageUrl,
    ) async {

      // 🔥 NO MORE FILE UPLOAD HERE (already done in UI)
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'Resolved',
        'afterImages': FieldValue.arrayUnion([imageUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _addTimelineEvent(
        complaintId,
        'Resolved',
        'Complaint resolved with proof',
      );

      await _sendNotification(
        citizenId,
        'Complaint Resolved',
        'Your complaint has been resolved',
      );
    }

  // ===============================
  // 5. UPDATE STATUS
  // ===============================
  Future<void> updateComplaintStatus(
      String complaintId, String status) async {

    await _firestore.collection('complaints').doc(complaintId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _addTimelineEvent(
      complaintId,
      status,
      'Status updated to $status',
    );
  }

  // ===============================
  // 6. GET TIMELINE
  // ===============================
  Future<List<TimelineEvent>> getTimeline(String complaintId) async {
    final snapshot = await _firestore
        .collection('complaints')
        .doc(complaintId)
        .collection('timeline')
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return TimelineEvent(
        status: data['status'] ?? '',
        message: data['message'] ?? '',
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
            DateTime.now(),
      );
    }).toList();
  }

  // ===============================
  // HELPER: TIMELINE
  // ===============================
  Future<void> _addTimelineEvent(
      String complaintId, String status, String message) async {

    await _firestore
        .collection('complaints')
        .doc(complaintId)
        .collection('timeline')
        .add({
      'status': status,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // HELPER: NOTIFICATION
  // ===============================
  Future<void> _sendNotification(
      String userId, String title, String message) async {

    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}