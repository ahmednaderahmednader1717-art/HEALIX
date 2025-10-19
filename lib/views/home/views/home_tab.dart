
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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

    // التصميم الأساسي الذي تم التصميم عليه
    const baseWidth = 430.0;
    const baseHeight = 932.0;

    // scale منفصل للعرض والارتفاع
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;

    final double toolbarHeight = 80 * h;

    // إعداد الـ Grid حسب حجم الشاشة
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      crossAxisCount = 2; // موبايل
      childAspectRatio = 1.2;
    } else if (screenWidth < 900) {
      crossAxisCount = 3; // تابلت صغير
      childAspectRatio = 1.2;
    } else if (screenWidth < 1200) {
      crossAxisCount = 4;
      childAspectRatio = 1.5;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    }

    // عدد العناصر المبدئية حسب حجم الشاشة
    int defaultGoals;
    if (screenWidth < 600) {
      defaultGoals = 2;
    } else if (screenWidth < 900) {
      defaultGoals = 3;
    } else {
      defaultGoals = Nutrient.nutrients.length;
    }

    // عدد العناصر المعروضة
    final goalsToShow = _showAllGoals
        ? Nutrient.nutrients.length
        : (Nutrient.nutrients.length >= defaultGoals
              ? defaultGoals
              : Nutrient.nutrients.length);

    // هل نعرض زر View All؟
    final bool showActionButton = Nutrient.nutrients.length > defaultGoals;

    return Stack(
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
              SectionTitle(
                title: "Welcome Back!",
                subtitle: "Track your day smartly",
                scale: h,
              ),
              Gap(16 * h),
              CustomSearchBar(scale: w),
              Gap(24 * h),

              // Today's Goals
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

              // GridView responsive
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
              Gap(8 * h),

              // Recommended Meals section
              RowHeader(
                title: "Recommended Meals",
                actionText: "",
                onAction: null,
                scale: w,
              ),
              Gap(12 * h),

              // Meals list
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 12 * h),
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
              Gap(28 * h),
            ],
          ),
        ),
      ],
    );
  }
}
