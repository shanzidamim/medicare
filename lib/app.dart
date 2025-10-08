import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:medicare/screen/login/splash_screen.dart';

import 'common/color_extension.dart';
import 'common/general_bindings.dart';
import 'common/globs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Globs.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Ancizar Serif",
        scaffoldBackgroundColor: TColor.bg,
        appBarTheme:  AppBarTheme(
          elevation: 0,
          backgroundColor: TColor.primary,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      initialBinding: GeneralBindings(),

      home: const SplashScreen(),
    );
  }
}