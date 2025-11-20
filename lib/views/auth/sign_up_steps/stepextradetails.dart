import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class StepExtraDetails extends StatelessWidget {
  final String? selectedGender;
  final String? genderError;
  final DateTime? selectedDate;
  final String? dobError;
  final int? selectedHeight;
  final String? heightError;
  final int? selectedWeight;
  final String? weightError;
  final int? selectedGoalWeight;
  final String? goalWeightError;

  final Function(String) onSelectGender;
  final Function(BuildContext) onSelectDate;
  final Function(BuildContext) onSelectHeight;
  final Function(BuildContext) onSelectWeight;
  final Function(BuildContext) onSelectGoalWeight;

  const StepExtraDetails({
    super.key,
    required this.selectedGender,
    required this.genderError,
    required this.selectedDate,
    required this.dobError,
    required this.selectedHeight,
    required this.heightError,
    required this.selectedWeight,
    required this.weightError,
    required this.selectedGoalWeight,
    required this.goalWeightError,
    required this.onSelectGender,
    required this.onSelectDate,
    required this.onSelectHeight,
    required this.onSelectWeight,
    required this.onSelectGoalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20 * h),
            Text(
              "A Few More Details",
              style: GoogleFonts.inriaSans(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Gap(20 * h),
            _sectionTitle("Gender"),
            if (genderError != null) _errorText(genderError!),
            Gap(8 * h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelectGender("Male"),
                    child: genderBox("Male", selectedGender == "Male"),
                  ),
                ),
                Gap(16 * h),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelectGender("Female"),
                    child: genderBox("Female", selectedGender == "Female"),
                  ),
                ),
              ],
            ),
            Gap(20 * h),
            _sectionTitle("Date of Birth"),
            if (dobError != null) _errorText(dobError!),
            Gap(8 * h),
            GestureDetector(
              onTap: () => onSelectDate(context),
              child: pickerBox(
                selectedDate == null
                    ? "Select your birth date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                selectedDate != null,
              ),
            ),
            Gap(20 * h),
            _sectionTitle("Height (cm)"),
            if (heightError != null) _errorText(heightError!),
            Gap(8 * h),
            GestureDetector(
              onTap: () => onSelectHeight(context),
              child: pickerBox(
                selectedHeight == null
                    ? "Select your height"
                    : "$selectedHeight cm",
                selectedHeight != null,
              ),
            ),
            Gap(20 * h),
            _sectionTitle("Weight (kg)"),
            if (weightError != null) _errorText(weightError!),
            Gap(8 * h),
            GestureDetector(
              onTap: () => onSelectWeight(context),
              child: pickerBox(
                selectedWeight == null
                    ? "Select your weight"
                    : "$selectedWeight kg",
                selectedWeight != null,
              ),
            ),
            Gap(20 * h),
            _sectionTitle("Goal Weight (kg)"),
            if (goalWeightError != null) _errorText(goalWeightError!),
            Gap(8 * h),
            GestureDetector(
              onTap: () => onSelectGoalWeight(context),
              child: pickerBox(
                selectedGoalWeight == null
                    ? "Select your goal weight"
                    : "$selectedGoalWeight kg",
                selectedGoalWeight != null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inriaSans(
        fontSize: 16,
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _errorText(String error) {
    return Text(error, style: const TextStyle(color: Colors.red, fontSize: 12));
  }

  Widget pickerBox(String text, bool selected) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade600, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primarayColor,
          fontSize: 16,
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget genderBox(String label, bool selected) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade600,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
