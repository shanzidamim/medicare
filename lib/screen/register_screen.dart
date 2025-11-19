import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';
import 'package:medicare/screen/shared_prefs_helper.dart';
import 'package:medicare/screen/home/main_tab_screen.dart';
import 'package:medicare/screen/home/medical_shop/shop_profile_edit_screen.dart';

import '../common/color_extension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  int _userType = 1;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final resp = await ApiService().register(
        mobileCode: '+880',
        mobile: _mobileCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        userType: _userType,
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      );

      setState(() => _loading = false);

      if (resp.data['status'] == true) {
        final data = resp.data['data'] ?? {};
        final token = data['auth_token']?.toString() ?? '';
        final userId = int.tryParse('${data['user_id']}') ?? 0;
        final name = data['first_name']?.toString() ?? '';

        await SPrefs.saveSession(
          token: token,
          userId: userId,
          userType: _userType,
          divisionName: 'Dhaka',
          name: name,
        );

        ApiService().setAccessToken(token);

        if (!mounted) return;

        if (_userType == 3) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ShopProfileEditScreen()),
                (_) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainTabScreen(
              initialDivision: 'Dhaka',
              currentUserId: userId,
            )),
                (_) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.data['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleItems = const [
      DropdownMenuItem(value: 1, child: Text('User / Patient')),
      DropdownMenuItem(value: 2, child: Text('Doctor')),
      DropdownMenuItem(value: 3, child: Text('Medical Shop')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Row(children: [
              const Text('Register as:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _userType,
                items: roleItems,
                onChanged: (v) => setState(() => _userType = v ?? 1),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+880 ',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Mobile required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.length < 4) ? 'Min 4 chars' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
              validator: (v) => v != _passwordCtrl.text ? 'Passwords don’t match' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                ),
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Register & Continue'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
