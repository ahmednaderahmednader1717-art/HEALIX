import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class HealixPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final Widget? leading; // optional leading icon/logo

  const HealixPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 60,
    this.borderRadius = 80,
    this.backgroundColor = AppColors.primarayColor,
    this.textColor = Colors.white,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.padding,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Text(
          text,
          style: GoogleFonts.inriaSans(
            fontSize: fontSize,
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );

    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: buttonChild,
    );

    if (width == null) {
      return SizedBox(height: height, width: double.infinity, child: button);
    }
    return SizedBox(height: height, width: width, child: button);
  }
}

