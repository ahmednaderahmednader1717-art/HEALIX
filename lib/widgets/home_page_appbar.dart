import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class HomePageAppBar extends StatelessWidget {
  final double toolbarHeight;
  final double w;
  final double scale;
  final String userName; // <--- الاسم هنا

  const HomePageAppBar({
    super.key,
    required this.toolbarHeight,
    required this.w,
    required this.scale,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: toolbarHeight,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              color: const Color(0x991C1C1E),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28 * scale,
                      backgroundImage: const AssetImage(
                        "assets/covers/IMG_1049.JPG",
                      ),
                    ),
                    Gap(10 * w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi $userName", // <--- عرض الاسم
                          style: GoogleFonts.inriaSans(
                            color: Colors.white,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Mon, 17 Sep",
                          style: GoogleFonts.inriaSans(
                            color: AppColors.secondaryColor,
                            fontSize: 14 * scale,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _GlassIconButton(
                      scale: scale,
                      icon: Icons.notifications_outlined,
                      badgeText: '2',
                      onPressed: () {},
                    ),
                    Gap(20 * w),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final double scale;
  final IconData icon;
  final String? badgeText;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.scale,
    required this.icon,
    this.badgeText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x33262626),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 10),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Badge(
          label: badgeText != null ? Text(badgeText!) : null,
          child: Icon(icon, color: Colors.white, size: 28 * scale),
        ),
      ),
    );
  }
}
