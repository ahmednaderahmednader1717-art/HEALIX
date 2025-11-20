import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class StepBodyType extends StatelessWidget {
  final String? selectedBodyType;
  final String? errorText;
  final Function(String) onSelect;

  static final Map<String, Map<String, dynamic>> bodyTypes = {
    "Ectomorph": {
      "desc":
          "Slim build, narrow frame, difficulty gaining mass, fast metabolism.",
      "iconAsset": "assets/icons/ectomorph.svg",
      "color": Colors.lightBlueAccent,
    },
    "Mesomorph": {
      "desc": "Athletic build, can gain muscle easily, moderate metabolism.",
      "iconAsset": "assets/icons/mesomorph.svg",
      "color": Colors.greenAccent,
    },
    "Endomorph": {
      "desc":
          "Stockier build, gains fat more easily, slow metabolism, may find losing weight difficult.",
      "iconAsset": "assets/icons/endomorph.svg",
      "color": Colors.deepOrangeAccent,
    },
  };

  const StepBodyType({
    super.key,
    required this.selectedBodyType,
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
    final scale = min(w, h);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20 * h),
            Text(
              "Select Your Body Type",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22 * scale,
                color: Colors.white,
              ),
            ),
            Gap(20 * h),
            if (errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 2 * h, bottom: 10 * h),
                child: Text(
                  errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 13 * scale),
                ),
              ),
            Gap(12 * h),
            ...bodyTypes.entries.map((e) {
              final isSelected = selectedBodyType == e.key;
              final Color color =
                  (e.value["color"] as Color?) ?? Colors.blueGrey;
              final String assetPath = e.value["iconAsset"] as String? ?? '';
              final String desc = e.value["desc"] as String? ?? '';
              return AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 240),
                margin: EdgeInsets.only(bottom: 14 * h),
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
                      padding: EdgeInsets.all(20 * h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18 * scale),
                        border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.8)
                              : Colors.grey.shade700,
                          width: 2.2 * w,
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
                            radius: 24 * scale,
                            backgroundColor: color.withOpacity(0.16),
                            child: SvgPicture.asset(
                              assetPath,
                              width: 40 * w,
                              height: 40 * h,
                              color: color,
                            ),
                          ),

                          SizedBox(width: 18 * w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key,
                                  style: TextStyle(
                                    color: isSelected ? color : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18 * scale,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                SizedBox(height: 7 * h),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14 * scale,
                                    height: 1.35 * h,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: EdgeInsets.only(
                                left: 10 * w,
                                top: 2 * h,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: color,
                                size: 27 * scale,
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
