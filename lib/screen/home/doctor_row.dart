import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../common/color_extension.dart';

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
    // Doctor data from API
    final name = doctor['full_name'] ?? "Unknown Doctor";
    final degrees = doctor['degrees'] ?? "";
    final category = doctor['category_name'] ?? "";
    final division = doctor['division_name'] ?? "";
    final imageUrl = doctor['image_url'] ?? "";
    final double rating = double.tryParse(doctor['rating']?.toString() ?? "0") ?? 0.0;

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
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset("assets/image/default_doctor.png",
                        width: 70, height: 70, fit: BoxFit.cover),
              )
                  : Image.asset(
                "assets/image/default_doctor.png",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // ===== Doctor Info =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Doctor Name ---
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

                  // --- Doctor Degree ---
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

                  // --- Specialist Category ---
                  Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // --- Division (Optional) ---


                  const SizedBox(height: 5),

                  // ===== Dynamic Rating =====
                  Row(
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: RatingStars(
                          value: rating,
                          starCount: 5,
                          starSize: 14,
                          valueLabelVisibility: false,
                          starSpacing: 2,
                          starOffColor: const Color(0xffC4C4C4),
                          starColor: const Color(0xffDE6732),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${rating.toStringAsFixed(1)})",
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

            // ===== Arrow Icon =====
            Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
