import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../common/color_extension.dart';

class DoctorCell extends StatelessWidget {
  final Map<String, dynamic> obj;
  final VoidCallback onPressed;

  const DoctorCell({super.key, required this.obj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final name = obj["full_name"] ?? "Unknown Doctor";
    final category = obj["category_name"] ?? "";
    final degree = obj["degrees"] ?? "";
    final division = obj["division_name"] ?? "";
    final imageUrl = obj["image_url"] ?? "";
    final int feedbackCount = obj["feedback_count"] ?? 0;

    final double rating =
        double.tryParse(obj["rating"]?.toString() ?? "0.0") ?? 0.0;

    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 150,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              padding:
              const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 12),
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
                  // ===== Doctor Name =====
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // ===== Doctor Degree =====
                  Text(
                    degree,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ===== Specialist =====
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),



                  const SizedBox(height: 5),

                  // ===== Rating =====
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

            // ===== Doctor Image =====
            // ===== Doctor Image =====
            Positioned(
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.white, // background to avoid black edges
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,        // ⭐ full image visible
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          "assets/image/default_doctor.png",
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                  )
                      : Image.asset(
                    "assets/image/default_doctor.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,        // ⭐ no cropping
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
