import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/screen/login/on_boarding_screen.dart';
import 'package:medicare/screen/login/select_city_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    loadNextScreen();

  }


  void loadNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    Get.off(() => const OnBoardingScreen());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Container(
        color: TColor.primaryTextW,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/image/splash_logo2.png"),
            const SizedBox(height: 5),
            Text(
              "Medicare",
              style: TextStyle(
                color: TColor.primary,
                fontSize: 24,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),



    );
  }
}