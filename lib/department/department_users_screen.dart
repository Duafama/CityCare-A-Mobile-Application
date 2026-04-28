import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DepartmentUsersScreen extends StatefulWidget {
  const DepartmentUsersScreen({super.key});

  @override
  State<DepartmentUsersScreen> createState() =>
      _DepartmentUsersScreenState();
}

class _DepartmentUsersScreenState extends State<DepartmentUsersScreen> {
  static const Color primaryBlue = Color(0xFF0A1F44);
  static const Color lightGrey = Color(0xFFF4F6F8);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> departmentUsers = [];
  bool isLoading = true;

  /// ---------------- VALIDATIONS ----------------
  String? validateName(String value) {
    if (value.trim().isEmpty) return "Name is required";
    if (value.trim().length < 2) return "Name too short";
    return null;
  }

  String? validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value.trim().isEmpty) return "Email is required";
    if (!emailRegex.hasMatch(value.trim())) return "Invalid email format";
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Min 6 characters required";
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    try {
      final departmentId =
          context.read<DepartmentProvider>().departmentId;

      if (departmentId == null) return;

      final snapshot = await _firestore
          .collection('users')
          .where('departmentId', isEqualTo: departmentId)
          .where('userType', isEqualTo: 'departmentUser')
          .get();

      setState(() {
        departmentUsers = snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool isCreating = false;
    bool obscurePassword = true;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.person_add, color: primaryBlue),
                  SizedBox(width: 10),
                  Text(
                    "Create Department User",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),

              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// NAME
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            validateName(value ?? ""),
                      ),

                      const SizedBox(height: 14),

                      /// EMAIL
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            validateEmail(value ?? ""),
                      ),

                      const SizedBox(height: 14),

                      /// PASSWORD
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            validatePassword(value ?? ""),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isCreating
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),

                TextButton(
                  onPressed: isCreating
                      ? null
                      : () async {

                          /// 🔥 VALIDATE FORM
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() => isCreating = true);

                          try {
                            final departmentId =
                                context
                                    .read<DepartmentProvider>()
                                    .departmentId!;

                            final apiKey =
                                dotenv.env['WEB_API_KEY'];

                            if (apiKey == null) {
                              throw Exception("API Key missing");
                            }

                            final response = await http.post(
                              Uri.parse(
                                "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey",
                              ),
                              headers: {
                                "Content-Type": "application/json",
                              },
                              body: jsonEncode({
                                "email": emailController.text.trim(),
                                "password":
                                    passwordController.text.trim(),
                                "returnSecureToken": false
                              }),
                            );

                            final data = jsonDecode(response.body);

                            if (data["error"] != null) {
                              throw Exception(
                                  data["error"]["message"]);
                            }

                            final uid = data["localId"];

                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
                                .set({
                              "uid": uid,
                              "name": nameController.text.trim(),
                              "email": emailController.text.trim(),
                              "departmentId": departmentId,
                              "userType": "departmentUser",
                              "isActive": true,
                              "createdAt":
                                  FieldValue.serverTimestamp(),
                            });

                            if (!mounted) return;
                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Department user created"),
                                backgroundColor: Colors.green,
                              ),
                            );

                            _loadUsers();
                          } catch (e) {
                            setDialogState(() => isCreating = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleUserStatus(
      String uid, bool currentStatus) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': !currentStatus,
    });

    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Manage Department Users",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserDialog,
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.person_add),
        label: const Text("Add User"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: departmentUsers.length,
              itemBuilder: (context, index) {
                final user = departmentUsers[index];

                return ListTile(
                  title: Text(user['name'] ?? ""),
                  subtitle: Text(user['email'] ?? ""),
                  trailing: Switch(
                    value: user['isActive'] ?? true,
                    onChanged: (val) =>
                        _toggleUserStatus(user['uid'], val),
                  ),
                );
              },
            ),
    );
  }
}