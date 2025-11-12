import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/common/globs.dart';
import 'package:medicare/screen/home/main_tab_screen.dart';
import 'package:medicare/screen/login/login_screen.dart';
import 'package:medicare/screen/login/splash_screen.dart';
import 'package:medicare/screen/shared_prefs_helper.dart';
import 'package:medicare/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Globs.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        scaffoldBackgroundColor: TColor.bg,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: TColor.primary,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
      home: const SplashRouter(),
    );
  }
}

/// SplashRouter decides: Splash → OnBoarding → Login OR direct to MainTab
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  bool _loading = true;
  Widget? _screen;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // show splash for short delay
    await Future.delayed(const Duration(seconds: 1));
    final session = await SPrefs.readSession();

    if (session == null) {
      setState(() {
        _loading = false;
        _screen = const SplashScreen(); // your default splash
      });
      return;
    }

    // restore session
    final token = session['access_token'] as String?;
    if (token != null && token.isNotEmpty) {
      ApiService().setAccessToken(token);
    }

    final userType = session['user_type'] as int? ?? 1;
    final division = session['division_name'] as String? ?? 'Dhaka';
    final userId = session['user_id'] as int? ?? 0;

    // ✅ All users now go to MainTabScreen
    Widget dest = MainTabScreen(
      initialDivision: division,
      currentUserId: userId,
    );

    setState(() {
      _loading = false;
      _screen = dest;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return _screen!;
  }
}
