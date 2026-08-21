//lib/features/user/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../database/app_database.dart';
import '../../database/daos/user_dao.dart';
import '../../database/tables/user_table.dart';
import '../../core/session.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = "staff"; // default role

  

  Future<void> _handleSignup() async {
    final userDao = getUserDao();

    try {
      // ✅ Check if this is the very first account
      final allUsers = await userDao.getAllUsers();
      if (allUsers.isEmpty) {
        _selectedRole = "owner"; // bootstrap owner
      } else {
        // ✅ Restrict staff/manager creation to owner/manager
        // Replace with actual session logic later
        final session = await Session.loadUserSession();
        final currentUserEmail = session?['email'];
        if (currentUserEmail == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No active session found")),
          );
          return;
        }
        final currentUser = await userDao.getUserByEmail(currentUserEmail);


        if (_selectedRole == "staff" || _selectedRole == "manager") {
          if (currentUser == null ||
              !(currentUser.role == "owner" || currentUser.role == "manager")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Only owner/manager can register staff or managers")),
            );
            return;
          }
        }
      }

      // ✅ Insert new user
      await userDao.insertUser(
        UsersCompanion.insert(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: Value(_selectedRole),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );

      context.go('/users'); // back to login
    } catch (e, stackTrace) {
      print("Error creating account: $e");
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Signup",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Role dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: const [
                DropdownMenuItem(value: "staff", child: Text("Staff")),
                DropdownMenuItem(value: "manager", child: Text("Manager")),
                DropdownMenuItem(value: "owner", child: Text("Owner")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Role",
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSignup,
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
