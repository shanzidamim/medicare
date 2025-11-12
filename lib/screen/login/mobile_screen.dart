import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../services/api_service.dart';
import '../home/home_tab_screen.dart';
import '../shared_prefs_helper.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    if (mobileController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter mobile and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().login(
        mobileCode: "+880",
        mobile: mobileController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      final data = response.data;

      if (data['status'] == true) {
        final user = data['data'];
        final int userId = user['user_id'];
        final int userType = user['user_type'];
        final String token = user['auth_token'] ?? '';
        final String divisionName = user['division_name'] ?? 'Dhaka';

        // ✅ Save session using named parameters (NOT map)
        await SPrefs.saveSession(
          userId: userId,
          userType: userType,
          token: token,
          divisionName: divisionName,
        );

        // ✅ Set access token globally
        ApiService().setAccessToken(token);

        // ✅ Navigate based on user type
        if (userType == 3) {
          // Medical Shop
          Navigator.pushReplacementNamed(context, '/shopProfileEdit');
        } else {
          // User / Doctor → go to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeTabScreen(
                selectedDivision: divisionName,
                currentUserId: userId,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login failed")),
        );
      }
    } catch (e) {
      debugPrint("❌ Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error connecting to server")),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Login to Medicare",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),

                // 🔹 Mobile Field
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixText: "+880 ",
                    border: OutlineInputBorder(),
                    labelText: "Mobile Number",
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔹 Register Link
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("Create a new account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
