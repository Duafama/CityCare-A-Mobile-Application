import 'package:flutter_test/flutter_test.dart';
import 'package:city_care/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('UT-5-1: toMap() should convert Category to Map correctly', () {
      final category = Category(
        id: 'cat1',
        name: 'Roads',
        departmentId: 'dept1',
        status: 'active',
      );

      final map = category.toMap();

      expect(map['id'], 'cat1');
      expect(map['name'], 'Roads');
      expect(map['departmentId'], 'dept1');
      expect(map['status'], 'active');
    });

    test('UT-5-2: fromMap() should create Category from Map correctly', () {
      final map = {
        'name': 'Garbage',
        'departmentId': 'dept2',
        'status': 'active',
      };

      final category = Category.fromMap('cat2', map);

      expect(category.id, 'cat2');
      expect(category.name, 'Garbage');
      expect(category.departmentId, 'dept2');
      expect(category.status, 'active');
    });

    test('UT-5-3: Category status can be updated', () {
      final category = Category(
        id: 'cat3',
        name: 'Electricity',
        departmentId: 'dept3',
        status: 'inactive',
      );

      expect(category.status, 'inactive');

      category.status = 'active';

      expect(category.status, 'active');
    });
  });
}
