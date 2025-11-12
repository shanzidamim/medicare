import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../common/color_extension.dart';

class ShopCell extends StatelessWidget {
  final Map obj;
  final VoidCallback onPressed;

  const ShopCell({super.key, required this.obj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final String name = obj["name"]?.toString() ?? "Unknown Shop";
    final String address = obj["address"]?.toString() ?? "Address not available";
    final String imageUrl = obj["image"]?.toString() ?? obj["image_url"]?.toString() ?? "";
    final double rating = double.tryParse(obj["rating"]?.toString() ?? "4.0") ?? 4.0;

    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 150,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // --- Bottom White Card ---
            Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  IgnorePointer(
                    ignoring: true,
                    child: RatingStars(
                      value: rating,
                      starCount: 5,
                      starSize: 10,
                      starOffColor: const Color(0xff7c7c7c),
                      starColor: const Color(0xffDE6732),
                      valueLabelVisibility: false,
                      maxValueVisibility: true,
                      animationDuration: const Duration(milliseconds: 800),
                      valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      valueLabelMargin: const EdgeInsets.only(right: 8),
                      onValueChanged: (_) {},
                    ),
                  ),
                  Text(
                    "(${rating.toStringAsFixed(1)})",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // --- Top Image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(imageUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        "assets/image/medical_shop.png",
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }

    // If image is hosted on API server (HTTP)
    if (imageUrl.startsWith("http")) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          "assets/image/medical_shop.png",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        ),
      );
    }

    // Otherwise treat as local asset
    return Image.asset(
      imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
    );
  }
}
