import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class HealixPrimaryButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final bool isLoading;
  final bool isDisabled;
  final bool isIconOnly;

  const HealixPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 55,
    this.borderRadius = 80,
    this.backgroundColor = AppColors.primarayColor,
    this.textColor = Colors.white,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.padding,
    this.leading,
    this.isLoading = false,
    this.isDisabled = false,
  }) : isIconOnly = false;

  /// 🔹 Constructor خاص لزر الأيقونة فقط
  const HealixPrimaryButton.iconOnly({
    super.key,
    required this.leading,
    required this.onPressed,
    this.width,
    this.height = 55,
    this.borderRadius = 80,
    this.backgroundColor = AppColors.primarayColor,
    this.isLoading = false,
    this.isDisabled = false,
  }) : text = null,
       textColor = Colors.white,
       fontSize = 18,
       fontWeight = FontWeight.bold,
       padding = EdgeInsets.zero,
       isIconOnly = true;

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading;

    Widget buttonChild;

    // ✅ لو بيحمّل
    if (isLoading) {
      buttonChild = const SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      );
    }
    // ✅ لو الزر أيقونة فقط
    else if (isIconOnly && leading != null) {
      buttonChild = Center(child: leading!);
    }
    // ✅ الحالة العادية (نص أو نص + أيقونة)
    else {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          if (text != null)
            Text(
              text!,
              style: GoogleFonts.inriaSans(
                fontSize: fontSize,
                color: textColor,
                fontWeight: fontWeight,
              ),
            ),
        ],
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveDisabled
              ? Colors.grey.shade800
              : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          elevation: 6,
          shadowColor: backgroundColor.withOpacity(0.3),
        ),
        onPressed: effectiveDisabled ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: buttonChild,
        ),
      ),
    );
  }
}
