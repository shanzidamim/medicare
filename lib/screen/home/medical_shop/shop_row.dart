import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

import '../../../common/color_extension.dart';

class ShopRow extends StatelessWidget {
  final Map obj;
  final VoidCallback onPressed;

  const ShopRow({super.key, required this.onPressed, required this.obj});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Image.asset(
            "assets/image/M1.webp",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 15),

          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "World Mart Pharmacy",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "7 No., Mannan Steel Corporation, \nDhaka - 2 Km",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  Row(
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
                              fontSize: 12.0),
                          valueLabelRadius: 0,
                          maxValue: 5,
                          starSpacing: 2,
                          maxValueVisibility: true,
                          valueLabelVisibility: false,
                          animationDuration: const Duration(milliseconds: 1000),
                          valueLabelPadding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 8),
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
                      )
                    ],
                  ),
                ],
              )),
          InkWell(
            onTap: () {},
            child: Icon(
              Icons.more_vert,
              color: TColor.black,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

