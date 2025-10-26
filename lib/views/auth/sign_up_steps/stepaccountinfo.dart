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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20),
          Text(
            "Create Your Account Details",
            style: GoogleFonts.inriaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Gap(10),
          Gap(16),
          Text(
            "Email Address",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: AppColors.secondaryColor,
            ),
          ),
          Gap(10),
          HealixTextField(
            controller: emailController,
            hint: "Enter Your Email Address",
            errorText: emailError,
          ),
          const SizedBox(height: 16),
          Text(
            "Enter Your Username",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: AppColors.secondaryColor,
            ),
          ),
          Gap(10),
          HealixTextField(
            controller: usernameController,
            hint: "Username",
            errorText: usernameError,
          ),
        ],
      ),
    );
  }
}
