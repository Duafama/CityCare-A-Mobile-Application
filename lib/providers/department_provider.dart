import 'package:flutter/material.dart';

class DepartmentProvider extends ChangeNotifier {
  String? _departmentId;
  String? _role; // 'officer' | 'user'

  String? get departmentId => _departmentId;
  String? get role => _role;

  bool get isOfficer => _role == 'officer';

  void setDepartment(String id, String role) {
    _departmentId = id;
    _role = role;
    notifyListeners();
  }

  void clear() {
    _departmentId = null;
    _role = null;
    notifyListeners();
  }
}