import 'package:flutter_test/flutter_test.dart';
import 'package:city_care/models/complaint.dart';

void main() {
  group('Complaint Model Tests', () {
    test('toMap() should convert Complaint to Map correctly', () {
      // Arrange - Create a complaint object
      final complaint = Complaint(
        complaintId: 'C001',
        citizenId: 'user123',
        citizenEmail: 'user@test.com',
        categoryId: 'cat_roads',
        categoryName: 'Roads',
        description: 'Large pothole on Main Street',
        latitude: 31.5204,
        longitude: 74.3587,
        location: 'Main Street, Lahore',
        priority: 'High',
        status: 'Pending',
        beforeImages: ['image1.jpg', 'image2.jpg'],
        afterImages: [],
        commentCount: 0,
        upvoteCount: 0,
      );

      // Act - Convert to Map
      final map = complaint.toMap();

      // Assert - Verify values
      expect(map['complaintId'], 'C001');
      expect(map['citizenId'], 'user123');
      expect(map['citizenEmail'], 'user@test.com');
      expect(map['categoryId'], 'cat_roads');
      expect(map['categoryName'], 'Roads');
      expect(map['description'], 'Large pothole on Main Street');
      expect(map['latitude'], 31.5204);
      expect(map['longitude'], 74.3587);
      expect(map['location'], 'Main Street, Lahore');
      expect(map['priority'], 'High');
      expect(map['status'], 'Pending');
      expect(map['beforeImages'].length, 2);
      expect(map['afterImages'].length, 0);
      expect(map['commentCount'], 0);
      expect(map['upvoteCount'], 0);
    });

    test('fromMap() should create Complaint from Map correctly', () {
      // Arrange - Create a map (simulating Firestore data)
      final map = {
        'complaintId': 'C002',
        'citizenId': 'user456',
        'citizenEmail': 'test@test.com',
        'categoryId': 'cat_garbage',
        'categoryName': 'Garbage',
        'description': 'Overflowing garbage bin',
        'latitude': 31.52,
        'longitude': 74.36,
        'location': 'Liberty Market',
        'priority': 'Medium',
        'status': 'Pending',
        'beforeImages': ['img1.jpg'],
        'afterImages': [],
        'commentCount': 0,
        'upvoteCount': 0,
      };

      // Act - Create Complaint from Map
      final complaint = Complaint.fromMap('C002', map);

      // Assert - Verify values
      expect(complaint.complaintId, 'C002');
      expect(complaint.citizenId, 'user456');
      expect(complaint.citizenEmail, 'test@test.com');
      expect(complaint.categoryId, 'cat_garbage');
      expect(complaint.categoryName, 'Garbage');
      expect(complaint.description, 'Overflowing garbage bin');
      expect(complaint.latitude, 31.52);
      expect(complaint.longitude, 74.36);
      expect(complaint.location, 'Liberty Market');
      expect(complaint.priority, 'Medium');
      expect(complaint.status, 'Pending');
      expect(complaint.beforeImages.length, 1);
      expect(complaint.afterImages.length, 0);
      expect(complaint.commentCount, 0);
      expect(complaint.upvoteCount, 0);
    });
  });
}
