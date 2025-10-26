import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/healix_text_field.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20),
          Text(
            "Create Your Password",
            style: GoogleFonts.inriaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Gap(10),
          Text(
            "Create a strong password to secure your account.",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Gap(16),
          Text(
            "Password",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: AppColors.secondaryColor,
            ),
          ),
          Gap(10),
          HealixTextField(
            controller: passwordController,
            hint: "Enter your password",
            isPassword: true,
            errorText: passwordError,
          ),
          const SizedBox(height: 16),
          HealixTextField(
            controller: confirmController,
            hint: "Re-enter your password",
            isPassword: true,
            errorText: confirmError,
          ),
        ],
      ),
    );
  }
}
