class Department {
  String id;
  String name;
  DateTime? createdAt;
  String status;

  Department({
    required this.id,
    required this.name,
    this.createdAt,
    this.status = "inactive",
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "createdAt": createdAt,
      "status": status,
    };
  }

  factory Department.fromMap(String id, Map<String, dynamic> map) {
    return Department(
      id: id,
      name: map["name"] ?? "",
      createdAt: map["createdAt"]?.toDate(),
      status: map["status"] ?? "inactive",
    );
  }
}
