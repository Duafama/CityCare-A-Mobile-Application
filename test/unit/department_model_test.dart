import 'package:flutter_test/flutter_test.dart';
import 'package:city_care/models/department.dart';

void main() {
  group('Department Model Tests', () {
    test('UT-6-1: toMap() should convert Department to Map correctly', () {
      final department = Department(
        id: 'dept1',
        name: 'Public Works',
        status: 'active',
      );

      final map = department.toMap();

      expect(map['id'], 'dept1');
      expect(map['name'], 'Public Works');
      expect(map['status'], 'active');
    });

    test('UT-6-2: fromMap() should create Department from Map correctly', () {
      final map = {
        'name': 'Electricity Department',
        'status': 'inactive',
      };

      final department = Department.fromMap('dept2', map);

      expect(department.id, 'dept2');
      expect(department.name, 'Electricity Department');
      expect(department.status, 'inactive');
    });

    test('UT-6-3: Department status can be activated', () {
      final department = Department(
        id: 'dept3',
        name: 'Sanitation',
        status: 'inactive',
      );

      expect(department.status, 'inactive');

      department.status = 'active';

      expect(department.status, 'active');
    });
  });
}
