import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final String deptId;

  const DepartmentDetailScreen({
    super.key,
    required this.deptId,
  });

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();

  String deptStatus = "active";
  bool loading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDepartment();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartment() async {
    final doc =
        await _firestore.collection('departments').doc(widget.deptId).get();

    final data = doc.data();

    _nameController.text = data?['name'] ?? "";
    deptStatus = data?['status'] ?? "active";

    setState(() => loading = false);
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please enter a department name"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await _firestore.collection('departments').doc(widget.deptId).update({
        "name": _nameController.text.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Department name updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _toggleDepartment() async {
    final newStatus = deptStatus == "active" ? "inactive" : "active";

    setState(() => isSaving = true);

    try {
      await _firestore.collection('departments').doc(widget.deptId).update({
        "status": newStatus,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // update users
      final users = await _firestore
          .collection('users')
          .where('departmentId', isEqualTo: widget.deptId)
          .get();

      for (var u in users.docs) {
        await u.reference.update({"isActive": newStatus == "active"});
      }

      // update categories
      final cats = await _firestore
          .collection('categories')
          .where('departmentId', isEqualTo: widget.deptId)
          .get();

      for (var c in cats.docs) {
        await c.reference.update({"status": newStatus});
      }

      setState(() => deptStatus = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == "active"
                ? "✅ Department activated successfully"
                : "⛔ Department deactivated successfully",
          ),
          backgroundColor: newStatus == "active" ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Department Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: (deptStatus == "active" ? Colors.green : Colors.red)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (deptStatus == "active" ? Colors.green : Colors.red)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    deptStatus == "active" ? Icons.check_circle : Icons.cancel,
                    color: deptStatus == "active" ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Status",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          deptStatus == "active" ? "Active" : "Inactive",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: deptStatus == "active"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header - Fixed for overflow
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.business,
                          color: primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Department Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 1.5,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),

                  // Department Name Field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: "Department Name",
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: "e.g., Public Works, Sanitation Department",
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 13),
                      prefixIcon:
                          Icon(Icons.business_outlined, color: primaryBlue),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.save, color: primaryBlue),
                        onPressed: isSaving ? null : _updateName,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            deptStatus == "active" ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: isSaving ? null : _toggleDepartment,
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  deptStatus == "active"
                                      ? Icons.block
                                      : Icons.check_circle,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  deptStatus == "active"
                                      ? "Deactivate Department"
                                      : "Activate Department",
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Officers Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Department Officers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1F44),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .where('departmentId', isEqualTo: widget.deptId)
                        .where('userType', isEqualTo: 'department_officer')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No officers assigned",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final u = docs[index].data() as Map<String, dynamic>;
                          final isActive = u['isActive'] ?? false;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child:
                                  const Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text(
                              u['name'] ?? "Unknown",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(u['email'] ?? "No email"),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? "Active" : "Inactive",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Department Users Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.people_alt,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Department Users",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1F44),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .where('departmentId', isEqualTo: widget.deptId)
                        .where('userType', isEqualTo: 'departmentUser')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No users assigned",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final u = docs[index].data() as Map<String, dynamic>;
                          final isActive = u['isActive'] ?? false;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.1),
                              child:
                                  const Icon(Icons.person, color: Colors.green),
                            ),
                            title: Text(
                              u['name'] ?? "Unknown",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(u['email'] ?? "No email"),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? "Active" : "Inactive",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Categories Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1F44),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('categories')
                        .where('departmentId', isEqualTo: widget.deptId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No categories created",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final c = docs[index].data() as Map<String, dynamic>;
                          final status = c['status'] ?? "inactive";
                          final isActive = status == "active";

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.1),
                              child: const Icon(Icons.category,
                                  color: Colors.orange),
                            ),
                            title: Text(
                              c['name'] ?? "Unknown",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
