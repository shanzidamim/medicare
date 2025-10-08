import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicare/screen/signup/verify_email.dart';

import '../../common/image.dart';
import '../../common/loaders.dart';
import '../../common/network_manager.dart';
import '../../data/exceptions/user_repository.dart';
import '../../data/repositories.authentication/authentication_repository.dart';
import '../../data/user_model.dart';
import 'full_screen_loader.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();


  ///variables
  final hidePassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();


  ///--Signup
  void signup() async {
    try {
      //start loading
      FullScreenLoader.openLoadingDialog('We are processing your information...', Images.loading);

      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        //remove loader
        FullScreenLoader.stopLoading();
        return;
      }


      //Form Validation
      if(!signupFormKey.currentState!.validate()) {
        //remove loader
        FullScreenLoader.stopLoading();
        return;
      }

      //privacy policy check
      if(!privacyPolicy.value) {
        Loaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message: 'In order to create an account, you must have to read and accept the privacy policy & terms od use.',
        );
        return;
      }

      //register user
      final userCredential =await AuthenticationRepository.instance.registerWithEmailAndPassword(email.text.trim(),password.text.trim());

      //save authenticated user data
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: username.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      //remove loader
      FullScreenLoader.stopLoading();

      //show success msg
      Loaders.successSnackBar(title: 'Congratulations', message: 'Your account has been created! Verify email to continue.');

      //move to verify email
      Get.to(() =>  VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      //remove loader
      FullScreenLoader.stopLoading();

      // show some generic error
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
  /// [PhoneNoAuthentication]
  Future<void> loginWithPhoneNumber(String phoneNo) async {
    try {
      await AuthenticationRepository.instance.loginWithPhoneNo(phoneNo);
    } catch (e) {
      throw e.toString();
    }
  }
}
