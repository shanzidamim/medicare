import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medicare/screen/password/forget_password.dart';

import '../../../common/color_extension.dart';
import '../../../common/sizes.dart';
import '../../../common/text_strings.dart';
import '../../../common/validator.dart';
import '../../signup/signup.dart';
import 'login_controller.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormKey,
      child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: TSizes.spaceBtwSections),
          child: Column(
            children: [

              /// Email
              TextFormField(
                controller: controller.email,
                validator: (value) => Validator.validateEmail(value),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    labelText: TTexts.email),
              ), // TextFormField
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Password
              Obx(
                    () =>
                    TextFormField(
                      controller: controller.password,
                      validator: (value) => Validator.validatePassword(value),
                      obscureText: controller.hidePassword.value,
                      decoration: InputDecoration(
                        labelText: TTexts.password,
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          onPressed: () =>
                          controller.hidePassword.value =
                          !controller.hidePassword.value,
                          icon: Icon(controller.hidePassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye),
                        ),
                      ),
                    ),
              ), // TextFormField
              const SizedBox(height: TSizes.spaceBtwInputFields / 2),

              /// Remember Me & Forget Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// Remember Me
                  Row(
                    children: [
                      Obx(() =>
                          Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: (value) =>
                              controller.rememberMe.value =
                              !controller.rememberMe.value),
                      ),
                      const Text(TTexts.rememberMe),
                    ],
                  ),

                  ///Forget Password
                  TextButton(
                      onPressed: () => Get.to(() => const ForgetPassword()),
                      child: const Text(TTexts.forgetPassword)),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              ///Sign In Button
              SizedBox(width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => controller.emailAndPasswordSignIn(),
                      child: const Text(TTexts.signIn))),
              const SizedBox(height: TSizes.spaceBtwItems),

              ///Create Account Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => Get.to(() => const SignupScreen()),
                    child: const Text(TTexts.createAccount)),
              ),
            ],
          )
      ),
    );
  }
}