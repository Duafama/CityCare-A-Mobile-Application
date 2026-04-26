class Category {
  String id;
  String name;
  String? departmentId;
  String status;

  Category({
    required this.id,
    required this.name,
    this.departmentId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "departmentId": departmentId,
      "status": status,
    };
  }

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      departmentId: map['departmentId'],
      status: map['status'] ?? 'inactive',
    );
  }
}
