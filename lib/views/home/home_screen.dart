import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// ignore: unused_import
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/nutrient.dart';
import 'package:test_splash/widgets/charts_widget.dart';
import 'package:test_splash/widgets/home_page_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    final double toolbarHeight = 80 * h;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16 * w,
              right: 16 * w,
              top: toolbarHeight,
              bottom: 120 * h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(24 * h),
                _SectionTitle(
                  title: "Welcome Back!",
                  subtitle: "Track your day smartly",
                  scale: scale,
                ),
                Gap(16 * h),
                _SearchBar(scale: scale),
                Gap(24 * h),
                _RowHeader(
                  title: "Today's Goals",
                  actionText: _showAllGoals ? "Show Less" : "View All",
                  onAction: () {
                    setState(() => _showAllGoals = !_showAllGoals);
                  },
                  scale: scale,
                ),
                Gap(12 * h),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _showAllGoals
                      ? Nutrient.nutrients.length
                      : (Nutrient.nutrients.length >= 2
                            ? 2
                            : Nutrient.nutrients.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8 * h,
                    crossAxisSpacing: 8 * w,
                    childAspectRatio: 1.38,
                  ),
                  itemBuilder: (context, index) {
                    final nutrient = Nutrient.nutrients[index];
                    return AppleRingCard(
                      title: nutrient.name,
                      value: nutrient.value,
                      color: nutrient.color,
                      scale: scale,
                    );
                  },
                ),
                Gap(8 * h),
                _RowHeader(
                  title: "Recommended Meals",
                  actionText: "See More",
                  onAction: () {},
                  scale: scale,
                ),
                Gap(12 * h),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  separatorBuilder: (_, __) => SizedBox(height: 12 * h),
                  itemBuilder: (context, index) {
                    final image = index.isEven
                        ? "assets/covers/IMG_1049.JPG"
                        : "assets/covers/IMG_1050.PNG";
                    return _MealTile(
                      imagePath: image,
                      title: "High Protein Bowl",
                      calories: 420,
                      scale: scale,
                    );
                  },
                ),
                Gap(28 * h),
              ],
            ),
          ),
          HomePageAppBar(toolbarHeight: toolbarHeight, w: w, scale: scale),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final double scale;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 16 * scale,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final double scale;

  const _SearchBar({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.white12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white70, size: 24 * scale),
          SizedBox(width: 8 * scale),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 16 * scale),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Search meals, plans, tips...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: Colors.white70, size: 22 * scale),
        ],
      ),
    );
  }
}

class _RowHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;
  final double scale;

  const _RowHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColors.primarayColor,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final int calories;
  final double scale;

  const _MealTile({
    required this.imagePath,
    required this.title,
    required this.calories,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16 * scale),
              bottomLeft: Radius.circular(16 * scale),
            ),
            child: Image.asset(
              imagePath,
              width: 110 * scale,
              height: 90 * scale,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orangeAccent,
                        size: 16 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        "$calories kcal",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12 * scale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarayColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  color: AppColors.primarayColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
