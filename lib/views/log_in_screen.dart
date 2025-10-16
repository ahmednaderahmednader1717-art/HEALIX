import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/healix_text_field.dart';
import 'package:test_splash/widgets/social_button.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:test_splash/views/sign_up_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
        title: SvgPicture.asset(
          "assets/logo/HEALIX.svg",
          width: 60 * scale,
          height: 40 * scale,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30 * w),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60 * h),
              Text(
                "Log In",
                style: GoogleFonts.inriaSans(
                  color: Colors.white,
                  fontSize: 40 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(40 * h),

              // 🟣 Username
              Text(
                "Enter Your Username",
                style: GoogleFonts.inriaSans(
                  fontSize: 17 * scale,
                  color: const Color.fromARGB(255, 169, 169, 169),
                ),
              ),
              Gap(10 * h),
              const SizedBox(height: 0),
              HealixTextField(controller: _emailController, hint: "Username"),
              Gap(25 * h),

              // 🟣 Password
              Text(
                "Enter Your Password",
                style: GoogleFonts.inriaSans(
                  fontSize: 17 * scale,
                  color: const Color.fromARGB(255, 169, 169, 169),
                ),
              ),
              Gap(10 * h),
              HealixTextField(
                controller: _passwordController,
                hint: "Password",
                isPassword: true,
              ),
              Gap(10 * h),
              Align( //FORGOT PASSWORD? TEXT BTN
                alignment: AlignmentGeometry.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.inriaSans(
                      fontSize: 17 * scale,
                      color: const Color.fromARGB(255, 169, 169, 169),
                    ),
                  )
                ),
              ),

              Gap(50 * h),

              // 🟣 Log In Button
              HealixPrimaryButton(
                text: "Log In",
                onPressed: () {}, // TODO: Add login logic
                height: 60 * h,
                fontSize: 20 * scale,
                borderRadius: 80 * scale,
              ),

              Gap(30 * h),

              // Divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Colors.white24, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * w),
                    child: Text(
                      "Or continue with",
                      style: GoogleFonts.inriaSans(
                        color: Colors.white54,
                        fontSize: 14 * scale,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Colors.white24, thickness: 1),
                  ),
                ],
              ),

              Gap(25 * h),

              // 🟢 Google Sign In Button
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

              // ⚪ Apple Sign In Button
              SocialElevatedButton(
                text: "Sign in with Apple",
                imagePath: "assets/icons/apple.png",
                size: scale,
                backgroundColor: Colors.white.withOpacity(0.08),
                onPressed: () {
                  // TODO SIGN IN WITH APPLE LOGIC HERE
                },
              ),

              Gap(40 * h),

              // 🟣 Sign Up Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: GoogleFonts.inriaSans(
                      fontSize: 16 * scale,
                      color: Colors.white70,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.inriaSans(
                        fontSize: 16 * scale,
                        color: AppColors.primarayColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(40 * h),
            ],
          ),
        ),
      ),
    );
  }
}
