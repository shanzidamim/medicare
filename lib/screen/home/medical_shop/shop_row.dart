import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../../common/color_extension.dart';

class ShopRow extends StatelessWidget {
  final Map obj;
  final VoidCallback onPressed;

  const ShopRow({
    super.key,
    required this.onPressed,
    required this.obj,
  });

  @override
  Widget build(BuildContext context) {
    final name = obj['full_name'] ?? obj['name'] ?? "Medical Shop";
    final address = obj['address'] ?? "Address not available";

    final int feedbackCount = obj['feedback_count'] ?? 0;

    final double rating = feedbackCount > 0
        ? double.tryParse(obj['rating']?.toString() ?? "0") ?? 0.0
        : 0.0;

    final imageUrl = obj['image_url']?.toString() ?? "";

    return InkWell(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                "assets/image/medical_shop.png",
                width: 100,
                height: 100,
              ),
            )
                : Image.asset(
              "assets/image/medical_shop.png",
              width: 100,
              height: 100,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // NAME
                  Text(
                    name,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // ADDRESS
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 13,
                    ),
                  ),

                  Row(
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: RatingStars(
                          value: rating,
                          starSize: 14,
                          starColor: const Color(0xffDE6732),
                          starOffColor: const Color(0xffC4C4C4),
                          valueLabelVisibility: false,
                          starCount: 5,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "($feedbackCount)",
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
          ),
        ],
      ),
    );
  }
}
