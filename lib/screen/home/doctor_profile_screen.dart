import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

import '../../common/color_extension.dart';
import 'doctor_row.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.close, color: Colors.white, size: 25),
        ),
        title: Text(
          "Doctors Profile",
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: TColor.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                ),

                Container(
                  width: double.maxFinite,
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 8,
                    top: 80,
                  ),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 8,
                    top: 80,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Dr. Abu Mohammad Shafique",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Cardiologist \n MBBS, MD",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                            ignoring: true,
                            child: RatingStars(
                              value: 3,
                              onValueChanged: (v) {},
                              starCount: 5,
                              starSize: 10,
                              valueLabelColor: const Color(0xff9b9b9b),
                              valueLabelTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0,
                              ),
                              valueLabelRadius: 0,
                              maxValue: 5,
                              starSpacing: 2,
                              maxValueVisibility: true,
                              valueLabelVisibility: false,
                              animationDuration: const Duration(
                                milliseconds: 1000,
                              ),
                              valueLabelPadding: const EdgeInsets.symmetric(
                                vertical: 1,
                                horizontal: 8,
                              ),
                              valueLabelMargin: const EdgeInsets.only(right: 8),
                              starOffColor: const Color(0xff7c7c7c),
                              starColor: const Color(0xffDE6732),
                            ),
                          ),
                          Text(
                            "(4.0)",
                            maxLines: 2,
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/image/dr.abuShafique.jpg",
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            Container(
              width: double.maxFinite,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Timings",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          ],
                        ),
                        Text(
                          "Sat-Thus ( 09:00am- 06:00pm)",
                          style: TextStyle(
                            color: TColor.unselect,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Services and Facility",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Senior Consultant",
                          style: TextStyle(
                            color: TColor.unselect,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Cardiac Surgery",
                          style: TextStyle(
                            color: TColor.unselect,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "See All",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Experience",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: TColor.primary,
                                      borderRadius: BorderRadius.circular(3)),
                                ),
                                Expanded(
                                  child: Text(
                                    "He is skilled and expert in diagnosis & management of all types of cardiac emergencies with invasive hemodynamic procedure, performing and reporting of Echocardiography.",
                                    style: TextStyle(
                                      color: TColor.unselect,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 8,
                          ),
                          itemCount: 2,
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Feedback",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "The service of the Dr. Abu Mohammad Shafique and staff is Good.",
                          style: TextStyle(
                            color: TColor.unselect,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                              color: const Color(0xffEDEDED),
                              borderRadius: BorderRadius.circular(25)),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Give Feedback",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Plot 15 Rd No 71, Dhaka 1212",
                            style: TextStyle(
                              color: TColor.unselect,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.phone,
                              size: 22,
                              color: TColor.primary,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Expanded(
                              child: Text(
                                "+8801914001214",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black26,
                    height: 1,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Other Staff",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            return DoctorRow(onPressed: () {});
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 8,
                          ),
                          itemCount: 3,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}