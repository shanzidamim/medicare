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
    final rating = double.tryParse(obj['rating']?.toString() ?? "4.0") ?? 4.0;
    final imageUrl = obj['image_url'] ?? "assets/image/medical_shop.png";

    return InkWell(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.startsWith("http")
                ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                : Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    IgnorePointer(
                      ignoring: true,
                      child: RatingStars(
                        value: rating,
                        onValueChanged: (_) {},
                        starCount: 5,
                        starSize: 14,
                        starOffColor: const Color(0xff7c7c7c),
                        starColor: const Color(0xffDE6732),
                        valueLabelVisibility: false,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(${rating.toStringAsFixed(1)})",
                      style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: TColor.black, size: 26),
        ],
      ),
    );
  }
}
