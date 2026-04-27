import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory({
    required String name,
    required String departmentId,
  }) async {
    try {
      String id = _firestore.collection('categories').doc().id;

      Category category = Category(
        id: id,
        name: name,
        departmentId: departmentId,
        status: "active",
      );

      // 1. Save category
      await _firestore.collection('categories').doc(id).set(category.toMap());

      // 2. Activate department
      await _firestore
          .collection('departments')
          .doc(departmentId)
          .update({"status": "active"});

      // 3. Activate officers
      var officers = await _firestore
          .collection('users')
          .where('departmentId', isEqualTo: departmentId)
          .get();

      for (var doc in officers.docs) {
        await doc.reference.update({"isActive": true});
      }
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  Future<List<Category>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();

    return snapshot.docs
        .map((doc) => Category.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Category>> getCategoriesByDepartment(String departmentId) async {
  final snapshot = await _firestore
      .collection('categories')
      .where('departmentId', isEqualTo: departmentId)
      .get();

  return snapshot.docs
      .map((doc) => Category.fromMap(doc.id, doc.data()))
      .toList();
}
}
