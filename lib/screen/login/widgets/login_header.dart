import 'package:flutter/material.dart';

import '../../../common/helper_functions.dart';
import '../../../common/sizes.dart';
import '../../../common/text_strings.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: AssetImage("assets/image/splash_logo2.png"),
        ),
        const SizedBox(height: TSizes.xl),

        Text(
          TTexts.loginTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.black, // 👈 Change to your desired color
          ),
        ),
        const SizedBox(height: TSizes.sm),
      ],
    );
  }
}