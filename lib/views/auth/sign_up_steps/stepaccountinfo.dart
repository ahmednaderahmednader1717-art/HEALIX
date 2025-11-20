import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/healix_text_field.dart';

class StepAccountInfo extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final String? emailError;
  final String? usernameError;

  const StepAccountInfo({
    super.key,
    required this.emailController,
    required this.usernameController,
    this.emailError,
    this.usernameError,
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
              "Create Your Account Details",
              style: GoogleFonts.inriaSans(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Gap(10 * h),
            Gap(16 * h),
            Text(
              "Email Address",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: AppColors.secondaryColor,
              ),
            ),
            Gap(10 * h),
            HealixTextField(
              controller: emailController,
              hint: "Enter Your Email Address",
              errorText: emailError,
            ),
            SizedBox(height: 16 * h),
            Text(
              "Enter Your Username",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: AppColors.secondaryColor,
              ),
            ),
            Gap(10 * h),
            HealixTextField(
              controller: usernameController,
              hint: "Username",
              errorText: usernameError,
            ),
          ],
        ),
      ),
    );
  }
}
