import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/models/cover_model.dart';
import 'package:test_splash/views/auth/log_in_screen.dart';
import 'package:test_splash/views/auth/sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // مقاسات التصميم الأصلية (iPhone 14 Pro Max)
    const baseWidth = 430.0;
    const baseHeight = 932.0;

    // نسب التناسب
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h); // 👈 المفتاح لتصميم متناسق على كل الشاشات

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Gap(40 * h),

                // 🟣 Title
                Text(
                  "Welcome to",
                  style: GoogleFonts.inriaSans(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                Gap(10 * h),

                // 🟣 Logo
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inriaSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "HEALI"),
                      TextSpan(
                        text: "X",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                Gap(60 * h),

                // 🟣 Carousel
                CarouselSlider.builder(
                  itemCount: CoverModel.covers.length,
                  itemBuilder: (context, index, realIndex) {
                    final cover = CoverModel.covers[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 300 * w,
                          height: 360 * h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20 * scale),
                            image: DecorationImage(
                              image: AssetImage(cover.coverImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Gap(15 * h),
                        Text(
                          cover.coverName,
                          style: GoogleFonts.inriaSans(
                            fontSize: 20 * scale,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    scrollPhysics: const BouncingScrollPhysics(),
                    height: 430 * h,
                    viewportFraction: 0.8,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() => _current = index);
                    },
                  ),
                ),

                // 🟣 Modern Animated Dots Indicator
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    key: ValueKey<int>(_current),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(CoverModel.covers.length, (index) {
                      final isActive = _current == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 5 * scale),
                        width: isActive ? 22 * scale : 8 * scale,
                        height: 8 * scale,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10 * scale),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.6,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),
                ),

                Gap(40 * h),

                // 🟣 Sign Up button
                SizedBox(
                  width: 288 * w,
                  height: 60 * h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80 * scale),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.inriaSans(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Gap(30 * h),

                // 🟣 Log in text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already Have An Account?",
                      style: GoogleFonts.inriaSans(
                        fontSize: 18 * scale,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const LogInScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Log In",
                        style: GoogleFonts.inriaSans(
                          fontSize: 18 * scale,
                          color: colorScheme.primary,
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
      ),
    );
  }
}
