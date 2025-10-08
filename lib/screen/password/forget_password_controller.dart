import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicare/screen/password/reset_password.dart';

import '../../common/image.dart';
import '../../common/loaders.dart';
import '../../common/network_manager.dart';
import '../../data/repositories.authentication/authentication_repository.dart';
import '../signup/full_screen_loader.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  sendPasswordResetEmail() async {
    try {
      FullScreenLoader.openLoadingDialog('Processing your request....', Images.loading);


      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) {FullScreenLoader.stopLoading();return;}

      if(!forgetPasswordFormKey.currentState!.validate()){
        FullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

      FullScreenLoader.stopLoading();

      Loaders.successSnackBar(title: 'Email Sent', message: 'Email Link Sent to Reset your Password'.tr);

      Get.to(() => ResetPasswordScreen(email: email.text.trim()));

    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  resendPasswordResetEmail(String email) async {
    try {
      FullScreenLoader.openLoadingDialog('Processing your request....', Images.loading);


      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) {FullScreenLoader.stopLoading();return;}



      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      FullScreenLoader.stopLoading();

      Loaders.successSnackBar(title: 'Email Sent', message: 'Email Link Sent to Reset your Password'.tr);



    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }



}
