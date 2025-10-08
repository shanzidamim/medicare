import 'package:flutter/material.dart';
import 'package:medicare/screen/signup/signup_form.dart';

import '../../common/color_extension.dart';
import '../../common/sizes.dart';
import '../../common/text_strings.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🔹 No color
        elevation: 0,
        iconTheme: IconThemeData(
          color: TColor.primary,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///Title
              Text(TTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black),
              ), //
              const SizedBox(height: TSizes.spaceBtwSections),

              ///Form
              const SignupForm(),
              const SizedBox(height: TSizes.spaceBtwInputFields),
            ],
          ),
        ),
      ),
    );
  }
}
