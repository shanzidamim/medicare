import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:medicare/screen/signup/signup_controller.dart';

import '../../common/color_extension.dart';
import '../../common/helper_functions.dart';
import '../../common/sizes.dart';
import '../../common/text_strings.dart';


class TTermsAndConditionCheckout extends StatelessWidget {
  const TTermsAndConditionCheckout({
    super.key,

  });


  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final dark = HelperFunctions.isDarkMode(context);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
                () => Checkbox(
                value: controller.privacyPolicy.value,
                onChanged: (value) => controller.privacyPolicy.value = !controller.privacyPolicy.value),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: '${TTexts.iAgreeTo} ', style: Theme.of(context).textTheme.bodySmall),
            TextSpan(text: TTexts.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium!.apply(
              color: dark ? TColor.white : TColor.primary,
              decorationColor: dark ? TColor.white : TColor.primary,
            )),
            TextSpan(text: '${TTexts.and} ', style: Theme.of(context).textTheme.bodySmall),
            TextSpan(text: TTexts.termsOfUse, style: Theme.of(context).textTheme.bodyMedium!.apply(
              color: dark ? TColor.white : TColor.primary,
              decorationColor: dark ? TColor.white : TColor.primary,
            )),
          ]),
        ),
      ],
    );
  }
}