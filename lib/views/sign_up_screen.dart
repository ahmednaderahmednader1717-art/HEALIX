import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:test_splash/widgets/social_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Sign Up",
          style: GoogleFonts.inriaSans(
            color: Color(0xffD3D3D3),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            return Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25 * w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Gap(240 * h),
              Text(
                "Welcome! Let's customize\nHEALIX for your goals.",
                style: GoogleFonts.inriaSans(
                  color: Colors.white,
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(h * 20),
              HealixPrimaryButton(
                text: "Continue",
                borderRadius: scale * 5,
                onPressed: () {},
              ),
              Gap(h * 20),
              Text(
                "OR",
                style: GoogleFonts.inriaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: scale * 20,
                ),
              ),
              Gap(h * 20),
              SocialElevatedButton(
                text: "Continue with Google",
                imagePath: "assets/icons/google.png",
                size: scale,
                backgroundColor: Colors.white.withOpacity(0.08),
                onPressed: () {
                  // TODO SIGN IN WITH GOOGLE LOGIC HERE
                },
              ),
              Gap(h * 10),
              SocialElevatedButton(
                text: "Sign in with Apple",
                imagePath: "assets/icons/apple.png",
                size: scale,
                backgroundColor: Colors.white.withOpacity(0.08),
                onPressed: () {
                  // TODO SIGN IN WITH APPLE LOGIC HERE
                },
              ),
              Gap(50 * h),
              Column(
                children: [
                  Text(
                    "We will collect personal information from and about\n you and use it for various purposes, including to\n customize your HEALIX experience. Read more\nabout the purposes, our practices, your choices, and",
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15 * scale,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "your rights in our ",
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15 * scale,
                    ),
                  ),
                  Text(
                    "Privacy Policy",
                    style: GoogleFonts.inriaSans(
                      color: AppColors.primarayColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15 * scale,
                    ),
                  ),
                  Text(
                    ".",
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15 * scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
