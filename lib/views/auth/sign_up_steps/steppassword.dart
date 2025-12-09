import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/common/healix_text_field.dart';

class StepPassword extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? passwordError;
  final String? confirmError;

  const StepPassword({
    super.key,
    required this.passwordController,
    required this.confirmController,
    this.passwordError,
    this.confirmError,
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
              "Create Your Password",
              style: GoogleFonts.inriaSans(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Gap(10 * h),
            Text(
              "Create a strong password to secure your account.",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            Gap(16 * h),
            Text(
              "Password",
              style: GoogleFonts.inriaSans(
                fontSize: 16 * scale,
                color: AppColors.secondaryColor,
              ),
            ),
            Gap(10 * h),
            HealixTextField(
              controller: passwordController,
              hint: "Enter your password",
              isPassword: true,
              errorText: passwordError,
            ),
            SizedBox(height: 16 * h),
            HealixTextField(
              controller: confirmController,
              hint: "Re-enter your password",
              isPassword: true,
              errorText: confirmError,
            ),
          ],
        ),
      ),
    );
  }
}
