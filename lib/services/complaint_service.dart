import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';

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
      "beforeImages": complaint.beforeImages, // ✅
      "afterImages": [], // empty initially
        });
    } catch (e) {
      throw Exception("Error adding complaint: $e");
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

  /// 4. Update status (admin/department use)
  Future<void> updateStatus(String complaintId, String status) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      "status": status,
      "updatedAt": DateTime.now(),
    });
  }

  /// 5. Delete complaint
  Future<void> deleteComplaint(String complaintId) async {
    await _firestore.collection('complaints').doc(complaintId).delete();
  }

}