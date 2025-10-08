import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class SectionRow extends StatelessWidget {
  final String title;
  final String buttonTitle;
  final VoidCallback onPressed;

  const SectionRow({super.key, required this.title,  this.buttonTitle = "See All", required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          InkWell(
            onTap: onPressed,
            child: Text(
              buttonTitle,
              style: TextStyle(
                  color: TColor.primary,
                  fontSize: 14,
                  decoration: TextDecoration.underline
              ),
            ),
          )
        ],
      ),
    );
  }
}
