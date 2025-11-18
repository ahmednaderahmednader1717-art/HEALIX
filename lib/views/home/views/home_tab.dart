import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/models/nutrient.dart';
import 'package:test_splash/views/home/widgets/charts_widget.dart';
import 'package:test_splash/views/home/widgets/custom_search_bar.dart';
import 'package:test_splash/views/home/widgets/meal_tile.dart';
import 'package:test_splash/views/home/widgets/row_header.dart';
import 'package:test_splash/views/home/widgets/section_tile.dart';

class HomeTab extends StatefulWidget {
  final void Function(int)? onTabChange;

  const HomeTab({super.key, this.onTabChange});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _showAllGoals = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const baseWidth = 430.0;
    const baseHeight = 932.0;

    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);

    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
      childAspectRatio = 1.2;
    } else if (screenWidth < 1200) {
      crossAxisCount = 4;
      childAspectRatio = 1.25;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    }

    int defaultGoals;
    if (screenWidth < 600) {
      defaultGoals = 2;
    } else if (screenWidth < 900) {
      defaultGoals = 3;
    } else {
      defaultGoals = Nutrient.nutrients.length;
    }

    final goalsToShow = _showAllGoals
        ? Nutrient.nutrients.length
        : (Nutrient.nutrients.length >= defaultGoals
              ? defaultGoals
              : Nutrient.nutrients.length);

    final bool showActionButton = Nutrient.nutrients.length > defaultGoals;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16 * w,
        right: 16 * w,
        // لا يوجد بادينج سفلي كي لا يظهر فراغ زائد
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(40 * h),
          Row(
            children: [
              Text(
                "HEALIX",
                style: GoogleFonts.inriaSans(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                width: 60 * w,
                height: 40 * h,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 42, 38, 38),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/SVGs/fire-svgrepo-com.svg",
                      color: Colors.amber,
                      width: 20,
                      height: 20,
                    ),
                    Gap(5 * w),
                    Text(
                      "0",
                      style: GoogleFonts.inriaSans(
                        fontSize: 20 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(16 * h),
          CustomSearchBar(scale: w),
          Gap(24 * h),
          RowHeader(
            title: "Today's Goals",
            actionText: showActionButton
                ? (_showAllGoals ? "Show Less" : "View All")
                : "",
            onAction: showActionButton
                ? () {
                    setState(() => _showAllGoals = !_showAllGoals);
                  }
                : null,
            scale: w,
          ),
          Gap(12 * h),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero, // مهم لتجنب أي فراغ داخلي
            itemCount: goalsToShow,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 6 * h,
              crossAxisSpacing: 6 * w,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final nutrient = Nutrient.nutrients[index];
              return AppleRingCard(
                title: nutrient.name,
                value: nutrient.value,
                color: nutrient.color,
                scale: h,
              );
            },
          ),
          Gap(16 * h),
          RowHeader(
            title: "Recommended Meals",
            actionText: "",
            onAction: null,
            scale: w,
          ),
          Gap(16 * h),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            separatorBuilder: (_, __) => SizedBox(height: 8 * h), // gap صغير
            itemBuilder: (context, index) {
              final image = index.isEven
                  ? "assets/covers/IMG_1049.JPG"
                  : "assets/covers/IMG_1050.PNG";
              return MealTile(
                imagePath: image,
                title: "High Protein Bowl",
                calories: 420,
                scale: h,
              );
            },
          ),
          // احذف أي Gap أو SizedBox كبيرة تحت ListView نهائياً
        ],
      ),
    );
  }
}
