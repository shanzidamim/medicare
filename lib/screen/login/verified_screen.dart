import 'package:flutter/material.dart';
import 'package:medicare/screen/home/main_tab_screen.dart';
import 'package:medicare/screen/shared_prefs_helper.dart';

import '../../common/color_extension.dart';

class VerifiedScreen extends StatefulWidget {
  const VerifiedScreen({super.key});

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMain();
  }

  Future<void> _navigateToMain() async {
    await Future.delayed(const Duration(seconds: 2));

    final session = await SPrefs.readSession();
    final userId = session?['user_id'] ?? 0;
    final divisionName = session?['division_name'] ?? 'Dhaka';

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainTabScreen(
          initialDivision: divisionName,
          currentUserId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: TColor.primary, size: 80),
            const SizedBox(height: 10),
            const Text("You are Verified", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
