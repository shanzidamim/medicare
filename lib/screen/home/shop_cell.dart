import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../common/color_extension.dart';

class ShopCell extends StatelessWidget {
  final Map obj;
  final VoidCallback onPressed;

  const ShopCell({super.key, required this.obj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final String name =
        obj["full_name"]?.toString() ?? obj["name"]?.toString() ?? "Unknown Shop";

    final String address =
        obj["address"]?.toString() ?? "Address not available";

    final String imageUrl = obj["image_url"]?.toString() ?? "";

    final int feedbackCount = obj["feedback_count"] ?? 0;

    // ⭐ Use REAL RATING only when feedback exists
    final double rating = feedbackCount > 0
        ? double.tryParse(obj["rating"]?.toString() ?? "0") ?? 0.0
        : 0.0;

    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 150,
        height: 240,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 45,
              child: Container(
                width: 150,
                height: 160,
                padding: const EdgeInsets.fromLTRB(12, 55, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),

                    // Address
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 5),

                    // ⭐ Rating Row (Same as doctor)
                    Row(
                      children: [
                        RatingStars(
                          value: rating.toDouble(),
                          starCount: 5,
                          starSize: 12,
                          valueLabelVisibility: false,
                          starColor: Color(0xffDE6732),
                          starOffColor: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "($feedbackCount)",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    )

                  ],
                ),
              ),
            ),

            // SHOP IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/image/medical_shop.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
