import 'package:flutter/material.dart';

class DepartmentProvider extends ChangeNotifier {
  String? _departmentId;

  String? get departmentId => _departmentId;

  void setDepartmentId(String id) {
    _departmentId = id;
    notifyListeners(); // 🔥 updates UI if needed
  }

  void clear() {
    _departmentId = null;
    notifyListeners();
  }
}