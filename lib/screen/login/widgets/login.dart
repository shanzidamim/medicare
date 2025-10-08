import 'package:flutter/material.dart';

import '../../../common/sizes.dart';
import '../../../common/spacing_styles.dart';
import 'package:medicare/screen/login/widgets/login_form.dart';

import 'login_header.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              const LoginHeader(),
              const SizedBox(height: TSizes.spaceBtwSections),
// column


              /// Form
              const LoginForm(),


            ],// Form
          ), // Column
        ), // Padding
      ), // SingleChild scrollView
    );
  }
}


