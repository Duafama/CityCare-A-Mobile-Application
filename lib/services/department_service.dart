import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department.dart';
import 'auth_service.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ================= ADD DEPARTMENT =================
  Future<String?> addDepartment({
    required String departmentName,
    required String officerName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      String departmentId = _firestore.collection('departments').doc().id;

      Department department = Department(
        id: departmentId,
        name: departmentName,
        createdAt: DateTime.now(),
        status: "inactive",
      );

      await _firestore
          .collection('departments')
          .doc(departmentId)
          .set(department.toMap());

      await _authService.createDepartmentOfficer(
        name: officerName,
        email: email,
        password: password,
        phone: phone,
        departmentId: departmentId,
      );

      return null;
    } catch (e) {
      return "Error creating department: $e";
    }
  }

  // ================= GET ALL DEPARTMENTS (FIXED) =================
  Future<List<Department>> getAllDepartments() async {
    final snapshot = await _firestore.collection('departments').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Department.fromMap(doc.id, data);
    }).toList();
  }

  // ================= GET ONLY ACTIVE DEPARTMENTS (RECOMMENDED) =================
  Future<List<Department>> getActiveDepartments() async {
    final snapshot = await _firestore
        .collection('departments')
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      return Department.fromMap(doc.id, doc.data());
    }).toList();
  }

  // ================= GET INACTIVE DEPARTMENTS =================
  Future<List<Department>> getInactiveDepartments() async {
    final snapshot = await _firestore
        .collection('departments')
        .where('status', isEqualTo: 'inactive')
        .get();

    return snapshot.docs.map((doc) {
      return Department.fromMap(doc.id, doc.data());
    }).toList();
  }

  // ================= GET DEPARTMENT NAME =================
  Future<String> getDepartmentName(String id) async {
    final doc = await _firestore.collection('departments').doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return "Department";
    }

    final data = doc.data() as Map<String, dynamic>;

    return data['name'] ?? "Department";
  }
}
