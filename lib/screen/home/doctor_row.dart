import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../common/color_extension.dart';
import '../../services/api_service.dart'; // ✅ added this import for baseHost

class DoctorRow extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onPressed;

  const DoctorRow({
    super.key,
    required this.doctor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final name = doctor['full_name'] ?? "Unknown Doctor";
    final degrees = doctor['degrees'] ?? "";
    final category = doctor['category_name'] ?? "";
    final division = doctor['division_name'] ?? "";
    final imageUrl = doctor['image_url']?.toString() ?? "";
    final double rating = double.tryParse(doctor['rating']?.toString() ?? "0") ?? 0.0;

    // ✅ Dynamic full image URL with fallback
    final fullImageUrl = imageUrl.isNotEmpty
        ? (imageUrl.startsWith("http")
        ? imageUrl
        : "${ApiService().baseHost}/$imageUrl")
        : "";

    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Doctor Image =====
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.white,
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                  fullImageUrl,
                  fit: BoxFit.contain,        // ⭐ show full image, no cropping
                  errorBuilder: (context, error, _) =>
                      Image.asset("assets/image/default_doctor.png",
                          width: 70, height: 70, fit: BoxFit.contain),
                )
                    : Image.asset(
                  "assets/image/default_doctor.png",
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,        // ⭐ no cropping
                ),
              ),
            ),


            const SizedBox(width: 12),

            // ===== Doctor Info =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    degrees,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: RatingStars(
                          value: rating,
                          starCount: 5,
                          starSize: 14,
                          starSpacing: 2,
                          valueLabelVisibility: false,
                          starOffColor: const Color(0xffC4C4C4),
                          starColor: const Color(0xffDE6732),
                        ),
                      ),
                      const SizedBox(width: 4),

                      /// ⭐ SHOW ONLY FEEDBACK COUNT
                      Text(
                        "(${doctor['feedback_count'] ?? 0})",  // <--- NEW
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
