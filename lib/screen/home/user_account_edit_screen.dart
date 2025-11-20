import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';
import 'package:medicare/screen/shared_prefs_helper.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------- LOAD USER DETAILS ----------------
  Future<void> _loadUser() async {
    final data = await ApiService().getUserProfile();

    setState(() {
      _fullName.text = data['first_name']?.toString() ?? "";
      _email.text = data['email']?.toString() ?? "";
      _mobile.text = data['mobile']?.toString() ?? "";
      _loading = false;
    });
  }

  // ---------------- SAVE ----------------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final payload = {
      "first_name": _fullName.text.trim(),
      "email": _email.text.trim(),
      "mobile": _mobile.text.trim(),
      if (_password.text.isNotEmpty) "password": _password.text.trim(),
    };

    final success = await ApiService().updateUserProfile(payload);

    if (!mounted) return;

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Profile updated successfully" : "Update failed",
        ),
      ),
    );

    if (success) {
      _loadUser(); // reload updated info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) =>
                v!.isEmpty ? "Enter your name" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _email,
                decoration:
                const InputDecoration(labelText: "Email (optional)"),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _mobile,
                decoration: const InputDecoration(labelText: "Mobile"),
                validator: (v) =>
                v!.isEmpty ? "Enter mobile number" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _password,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: "Change Password"),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 45),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
