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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20),
          Text(
            "First, what can we call you?",
            style: GoogleFonts.inriaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Gap(10),
          Text(
            "HEALIX would like to get to know you.",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Gap(16),
          Text(
            "Preferred First Name",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: AppColors.secondaryColor,
            ),
          ),
          Gap(10),
          HealixTextField(
            controller: nameController,
            hint: "Enter Your Name",
            errorText: nameError,
          ),
          const SizedBox(height: 16),
          Text(
            "Phone Number",
            style: GoogleFonts.inriaSans(
              fontSize: 16,
              color: AppColors.secondaryColor,
            ),
          ),
          Gap(10),
          HealixTextField(
            controller: phoneController,
            hint: "Enter Your Phone Number",
            errorText: phoneError,
          ),
        ],
      ),
    );
  }
}
