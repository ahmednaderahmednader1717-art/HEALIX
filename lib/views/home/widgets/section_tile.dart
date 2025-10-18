import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final double scale;

  const SectionTitle({
    required this.title,
    required this.subtitle,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inriaSans(
            color: Colors.white,
            fontSize: 24 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          subtitle,
          style: GoogleFonts.inriaSans(
            color: AppColors.secondaryColor,
            fontSize: 16 * scale,
          ),
        ),
      ],
    );
  }
}
