import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:medicare/common_widget/category_button.dart';
import 'package:medicare/screen/home/medical_shop/medical_shop_list_screen.dart';
import 'package:medicare/screen/home/medical_shop/medical_shop_profile_screen.dart';
import 'package:medicare/screen/home/shop_cell.dart';

import '../../common/color_extension.dart';
import '../../common_widget/section_row.dart';
import 'category_filter_screen.dart';
import 'doctor_cell.dart';
import 'doctor_profile_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  List categoryArr = [
    {"title": "Heart Issue", "image": "assets/image/heart.png"},
    {"title": "Lung Issue", "image": "assets/image/lung.png"},
    {"title": "Cancer Issue", "image": "assets/image/cancer.png"},
    {"title": "Sugar Issue", "image": "assets/image/sugar.png"},
  ];

  List adsArr = [
    {"image": "assets/image/ad_1.png"},
    {"image": "assets/image/ad_2.png"},
  ];

  List nearDoctorArr = [
    {
      "name": "Dr. Abu Mohammed Shafique",
      "degree": "MBBS, MD (Cardiology)",
      "image": "assets/image/doctor_image.png",
    },
    {
      "name": "Dr. Sharif Ahmed",
      "degree": "MBBS, M.Phil (Radiotherapy)",
      "image": "assets/image/doctor_image.png",
    },
    {
      "name": "Dr. Arif Ahmed Mohiuddin",
      "degree": "MBBS, MS (Cardiothoracic Surgery)",
      "image": "assets/image/doctor_image.png",
    },

    {
      "name": "Dr. Arif Ahmed Mohiuddin",
      "degree": "MBBS, MS (Cardiothoracic Surgery)",
      "image": "assets/image/doctor_image.png",
    },
  ];

  List nearShopArr = [
    {
      "name": "World Mart Pharmacy",
      "address": "7 No., Mannan Steel Corporation, Dhaka - Mymensingh Rd",
      "image": "assets/image/medical_shop.png",
    },
    {
      "name": "Medicine Point",
      "address": "House 52 Ranavola Main Rd, Dhaka 1230",
      "image": "assets/image/medical_shop.png",
    },
    {
      "name": "Healthcare Pharmaceuticals",
      "address": "28 Road No. 1, Dhaka 1230",
      "image": "assets/image/medical_shop.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                itemBuilder: (context, index) {
                  var obj = categoryArr[index];
                  return CategoryButton(
                    title: obj["title"],
                    icon: obj["image"],
                    onPressed: () {
                      context.push(const CategoryFilterScreen());
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 25),
                itemCount: categoryArr.length,
              ),
            ),
            SizedBox(
              // color: Colors.red,
              height: context.width * 0.5,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                itemBuilder: (context, index) {
                  var obj = adsArr[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 1),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        obj["image"],
                        width: context.width * 0.85,
                        height: context.width * 0.425,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemCount: adsArr.length,
              ),
            ),
            SectionRow(title: "Doctors near by you", onPressed: () {}),
            SizedBox(
              height: 220,
              child: ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return DoctorCell(obj: nearDoctorArr[index] , onPressed: (){
                      context.push( const DoctorProfileScreen() );
                    });
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    width: 20,
                  ),
                  itemCount: nearDoctorArr.length),
            ),
            SectionRow(title: "Medical Shop near by you", onPressed: () {
              context.push( const MedicalShopListScreen() );
            }),
            SizedBox(
              height: 220,
              child: ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return ShopCell(
                        obj: nearShopArr[index], onPressed: () {
                      context.push(const MedicalShopProfileScreen());
                    });
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    width: 20,
                  ),
                  itemCount: nearShopArr.length),
            ),
          ],
        ),
      ),
    );
  }
}