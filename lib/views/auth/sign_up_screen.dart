import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/auth/multi_step_signup_page.dart';
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

    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Sign Up",
          style: GoogleFonts.inriaSans(
            color: Colors.white,
            fontSize: 22 * scale,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(250 * h),
              Text(
                "Welcome! Let’s customize\n HEALIX for your goals.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inriaSans(color: Colors.white, fontSize: 24),
              ),
              Gap(30 * h),
              HealixPrimaryButton(
                text: "Continue",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiStepSignUpPage(),
                    ),
                  );

                },
                borderRadius: 10,
              ),
              Gap(20 * h),
              Text(
                "OR",
                style: GoogleFonts.inriaSans(color: Colors.white, fontSize: 24),
              ),
              Gap(15 * h),
              SocialElevatedButton(
                text: "Sign in with Google",
                imagePath: "assets/icons/google.png",
                size: scale,
                backgroundColor: Colors.white.withOpacity(0.08),
                onPressed: () {
                  // TODO SIGN IN WITH GOOGLE LOGIC HERE
                },
              ),
              Gap(15 * h),
              SocialElevatedButton(
                text: "Sign in with Apple",
                imagePath: "assets/icons/apple.png",
                size: scale,
                backgroundColor: Colors.white.withOpacity(0.08),
                onPressed: () {
                  // TODO SIGN IN WITH APPLE LOGIC HERE
                },
              ),
              Gap(100 * h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inriaSans(
                    color: Colors.white,
                    fontSize: 15 * scale,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          "We will collect personal information from and about\nyou and use it for various purposes, including to\ncustomize your HEALIX experience. Read more\nabout the purposes, our practices, your choices, and\nyour rights in our  ",
                    ),
                    TextSpan(
                      text: "Privacy Policy",
                      style: GoogleFonts.inriaSans(
                        color: AppColors.primarayColor,
                        fontSize: 15 * scale,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: handle click, e.g., open privacy policy URL
                        },
                    ),
                  ],
                ),
              ),
              Gap(30 * h),
            ],
          ),
        ),
      ),
    );
  }
}
