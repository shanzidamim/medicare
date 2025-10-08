import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medicare/screen/home/home_tab_screen.dart';
import 'package:medicare/screen/home/medical_shop/menu/menu.dart';
import 'package:medicare/screen/home/medical_shop/menu/profile_screen.dart';
import 'package:medicare/screen/home/medical_shop/menu/settings_menu_tile.dart';
import 'package:medicare/screen/login/widgets/login.dart';

import '../../common/color_extension.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldStateKey,

      // Drawer
      drawer: Drawer(
        width: 350,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: TColor.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              scaffoldStateKey.currentState?.closeDrawer();
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Menu()
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SettingsMenuTile(icon: Iconsax.receipt, title: 'Medical Record', onTap: () {}),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  SettingsMenuTile(icon: Iconsax.message, title: 'Forum', onTap: () {}),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  SettingsMenuTile(icon: Iconsax.user_edit, title: 'Profile', onTap: () => Get.to(() => const ProfileScreen()),),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  SettingsMenuTile(icon: Iconsax.info_circle, title: 'Help', onTap: () {}),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  SettingsMenuTile(icon: Iconsax.logout, title: 'Logout', onTap: () => Get.to(() => const LoginScreen())),
                ],
              ),
            ),
          ],
        ),
      ),

      // AppBar
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            scaffoldStateKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu, size: 34, color: Colors.white),
        ),
        title: const Text(
          "Medicare",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16), // space from right edge
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {},
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: TColor.black,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Dhaka",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Body with ONE PAGE
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            height: 15,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
          ),
          const Expanded(
            child: HomeTabScreen(),
          ),
        ],
      ),
    );
  }
}