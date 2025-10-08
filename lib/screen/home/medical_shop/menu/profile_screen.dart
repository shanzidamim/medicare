import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medicare/screen/home/medical_shop/menu/profile_menu.dart';
import 'package:medicare/screen/home/medical_shop/menu/section_heading.dart';

import '../../../../common/color_extension.dart';
import '../../../../common/sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      ///body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [




              ///heading profile
              const SectionHeading(title: 'Profile Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              ProfileMenu(title: 'Name', value: 'shanzida', onPressed: () {}),
              ProfileMenu(title: 'Username', value: 'mim', onPressed: () {}),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              ///heading personal info
              const SectionHeading(title: 'Personal Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              ProfileMenu(title: 'User ID', value: '75799', icon: Iconsax.copy, onPressed: () {}),
              ProfileMenu(title: 'E-mail', value: 'shanzida@gmail', onPressed: () {}),
              ProfileMenu(title: 'Phone Number', value: '8916257458345', onPressed: () {}),

              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),



            ],
          ),
        ),
      ),
    );
  }
}
