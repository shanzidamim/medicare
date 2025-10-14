import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../common/helper_functions.dart';

class FullScreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) =>
          PopScope(
            canPop: false,
            child: Container(
              color: HelperFunctions.isDarkMode(Get.context!)
                  ? Colors.black
                  : Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  ///stop the currently open loading dialog
  ///this method doesn't return anything
  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
