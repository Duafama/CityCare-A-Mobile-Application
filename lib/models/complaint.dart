import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  String complaintId;
  String citizenId;
  String citizenEmail;
  String categoryId;
  String categoryName;
  String description;
  double latitude;
  double longitude;
  String location;
  String priority;
  String status;
  String? departmentId;
  String? departmentName;
  List<String> beforeImages;
  List<String> afterImages;
  int commentCount;
  int upvoteCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  Complaint({
    required this.complaintId,
    required this.citizenId,
    required this.citizenEmail,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.priority,
    required this.status,
    this.departmentId,
    this.departmentName,
    this.beforeImages = const [],
    this.afterImages = const [],
    required this.commentCount,
    required this.upvoteCount,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "complaintId": complaintId,
      "citizenId": citizenId,
      "citizenEmail": citizenEmail,
      "categoryId": categoryId,
      "categoryName": categoryName,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "location": location,
      "priority": priority,
      "status": status,
      "departmentId": departmentId,
      "departmentName": departmentName,
      "beforeImages": beforeImages,
      "afterImages": afterImages,
      "commentCount": commentCount,
      "upvoteCount": upvoteCount,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Complaint.fromMap(String id, Map<String, dynamic> map) {
    return Complaint(
      complaintId: id,
      citizenId: map["citizenId"] ?? "",
      citizenEmail: map["citizenEmail"] ?? "",
      categoryId: map["categoryId"] ?? "",
      categoryName: map["categoryName"] ?? "",
      description: map["description"] ?? "",
      latitude: (map["latitude"] ?? 0).toDouble(),
      longitude: (map["longitude"] ?? 0).toDouble(),
      location: map["location"] ?? "",
      priority: map["priority"] ?? "Medium",
      status: map["status"] ?? "Pending",
      departmentId: map["departmentId"],
      departmentName: map["departmentName"],
      beforeImages: List<String>.from(map["beforeImages"] ?? []),
      afterImages: List<String>.from(map["afterImages"] ?? []),
      commentCount: map["commentCount"] ?? 0,
      upvoteCount: map["upvoteCount"] ?? 0,
      createdAt: map["createdAt"]?.toDate(),
      updatedAt: map["updatedAt"]?.toDate(),
    );
  }
}
// STOP HERE - NOTHING AFTER THIS
