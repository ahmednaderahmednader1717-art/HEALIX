import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/healix_text_field.dart';

class StepPersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String? nameError;
  final String? phoneError;

  const StepPersonalInfo({
    super.key,
    required this.nameController,
    required this.phoneController,
    this.nameError,
    this.phoneError,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // مقاسات التصميم الأصلية (iPhone 14 Pro Max)
    const baseWidth = 430.0;
    const baseHeight = 932.0;

    // نسب التناسب
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h); // 👈 المفتاح لتصميم متناسق على كل الشاشات
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20 * h),
            Text(
              "First, what can we call you?",
              style: GoogleFonts.inriaSans(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Gap(10 * h),
            Text(
              "HEALIX would like to get to know you.",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            Gap(16 * h),
            Text(
              "Preferred First Name",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: AppColors.secondaryColor,
              ),
            ),
            Gap(10 * h),
            HealixTextField(
              controller: nameController,
              hint: "Enter Your Name",
              errorText: nameError,
            ),
            SizedBox(height: 16 * h),
            Text(
              "Phone Number",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: AppColors.secondaryColor,
              ),
            ),
            Gap(10 * h),
            HealixTextField(
              controller: phoneController,
              hint: "Enter Your Phone Number",
              errorText: phoneError,
            ),
          ],
        ),
      ),
    );
  }
}
