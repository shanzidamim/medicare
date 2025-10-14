import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare/common/text_strings.dart';

import '../../common/sizes.dart';
import '../../common/spacing_styles.dart';

class  SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.image, required this.title, required this.subTitle, required this.onPressed});

  final String image, title, subTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              ///Image
              Flexible(
                child: Lottie.asset(image, fit: BoxFit.contain),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              ///Title & Subtitle
              Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(subTitle, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwSections),

              ///Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: onPressed, child: const Text(TTexts.tContinue)),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
