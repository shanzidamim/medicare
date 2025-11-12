import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import 'package:medicare/screen/shared_prefs_helper.dart';
import 'package:medicare/screen/home/main_tab_screen.dart';
import '../register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  int _selectedType = 1; // For UI dropdown
  bool _busy = false;

  Future<void> _doLogin() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final res = await ApiService().login(
        mobileCode: '+880',
        mobile: _mobileCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (res.data is! Map || res.data['status'] != true) {
        _snack(res.data['message']?.toString() ?? 'Login failed');
        setState(() => _busy = false);
        return;
      }

      final data = res.data['data'] as Map;
      final token = data['auth_token']?.toString() ?? '';
      final userId = int.tryParse('${data['user_id']}') ?? 0;
      final userType = int.tryParse('${data['user_type']}') ?? _selectedType;
      final name = data['first_name']?.toString() ?? '';

      await SPrefs.saveSession(
        token: token,
        userId: userId,
        userType: userType,
        divisionName: 'Dhaka',
        name: name,
      );

      ApiService().setAccessToken(token);

      if (!mounted) return;

      // ✅ All user types go to MainTabScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainTabScreen(
            initialDivision: 'Dhaka',
            currentUserId: userId,
          ),
        ),
            (_) => false,
      );
    } catch (e) {
      _snack('Network error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: TColor.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in with your mobile & password',
                style: TextStyle(color: TColor.secondaryText),
              ),
              const SizedBox(height: 24),

              // 🔹 Account type dropdown (for UI only)
              DropdownButtonFormField<int>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('User')),
                  DropdownMenuItem(value: 2, child: Text('Doctor')),
                  DropdownMenuItem(value: 3, child: Text('Medical Shop')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Account type (for UI)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _selectedType = v ?? 1),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile (without +880)',
                  prefixText: '+880 ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter mobile' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.length < 4) ? 'Minimum 4 characters' : null,
              ),

              const SizedBox(height: 22),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _busy ? null : _doLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                  ),
                  child: _busy
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Create new account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
