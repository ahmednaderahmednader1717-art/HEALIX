import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StepDietType extends StatelessWidget {
  final String? selectedDietType;
  final String? errorText;
  final Function(String) onSelect;

  static final Map<String, Map<String, dynamic>> dietTypes = {
    "Standard": {
      "desc": "No diet restrictions.",
      "icon": Icons.restaurant, // أو asset
      "color": Colors.orangeAccent,
    },
    "Vegetarian": {
      "desc": "No meat or fish.",
      "icon": Icons.eco, // أو استخدم asset: "assets/icons/vegetarian.svg"
      "color": Colors.lightGreen,
    },
    "Vegan": {
      "desc": "No animal products at all.",
      "icon": Icons.spa, // أو asset
      "color": Colors.green,
    },
    "Pescatarian": {
      "desc": "Fish okay, but no other meat.",
      "icon": Icons.set_meal, // أو asset
      "color": Colors.teal,
    },
  };

  const StepDietType({
    super.key,
    required this.selectedDietType,
    required this.errorText,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    // ignore: unused_local_variable
    final scale = min(w, h);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16*w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20*h),
            Text(
              "Select Your Diet Type",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22*scale,
                color: Colors.white,
              ),
            ),
            Gap(20*h),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 10),
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            const Gap(12),
            ...dietTypes.entries.map((e) {
              final isSelected = selectedDietType == e.key;
              final Color color = (e.value["color"] as Color?) ?? Colors.blueGrey;
              final desc = e.value["desc"] as String? ?? '';
              // لو تريد icons صور غيّر هذا الجزء لما يناسبك
              // final String assetPath = e.value["iconAsset"] as String? ?? '';
              return AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.only(bottom: 14),
                child: Material(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(18),
                  elevation: isSelected ? 6 : 2,
                  shadowColor: color.withOpacity(0.25),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onSelect(e.key),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.8)
                              : Colors.grey.shade700,
                          width: 2.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: color.withOpacity(0.2),
                            child: Icon(
                              e.value["icon"] as IconData,
                              color: color,
                              size: 30*scale,
                            ),
                            // أو استخدم صورة asset:
                            // child: SvgPicture.asset(assetPath, ...)
                          ),
                          SizedBox(width: 18*w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key,
                                  style: TextStyle(
                                    color: isSelected ? color : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18*scale,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                SizedBox(height: 7*h),
                                Text(
                                  desc,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 2),
                              child: Icon(
                                Icons.check_circle,
                                color: color,
                                size: 27,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
