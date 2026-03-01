import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/models/nutrient.dart';
import 'package:test_splash/widgets/home/charts_widget.dart';
import 'package:test_splash/views/home/widgets/day_selector.dart';
import 'package:test_splash/views/home/widgets/meal_tile.dart';
import 'package:test_splash/views/home/widgets/row_header.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/food_model.dart';
import 'package:test_splash/services/food_service.dart';
import 'package:test_splash/services/auth_service.dart';

class HomeTab extends StatefulWidget {
  final void Function(int)? onTabChange;

  const HomeTab({super.key, this.onTabChange});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _showAllGoals = false;
  DateTime selectedDay = DateTime.now();
  late Future<List<Food>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _foodsFuture = FoodService().getFoods();
  }

  void onDaySelected(DateTime day) {
    setState(() {
      selectedDay = day;
    });
  }

  Future<void> _onRefresh() async {
    await AuthService().refreshToken();
    final fetchFuture = FoodService().getFoods();
    setState(() {
      _foodsFuture = fetchFuture;
    });
    await fetchFuture;
  }

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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _onRefresh),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16 * h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70 * h),
                FutureBuilder<List<Food>>(
                  future: _foodsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20 * h),
                          child: const CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * w),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 32 * w,
                            fontWeight: FontWeight.bold,
                          ),
                          children: const [
                            TextSpan(
                              text: "HEALI",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: "X",
                              style: TextStyle(color: AppColors.primarayColor),
                            ),
                          ],
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
                              color: Colors.black.withValues(alpha: 0.35),
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
                              colorFilter: const ColorFilter.mode(
                                Colors.amber,
                                BlendMode.srcIn,
                              ),
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
                ),
                SizedBox(height: 14 * h),
                DaySelector(
                  selectedDay: selectedDay,
                  onDaySelected: onDaySelected,
                  caloriesProgress: {DateTime(2026, 2, 16): .75},
                ),

                SizedBox(height: 8 * h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * w),
                  child: RowHeader(
                    title: "Todays's Total Nutrations",
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
                ),
                SizedBox(height: 12 * h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * w),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
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
                        scale: scale,
                      );
                    },
                  ),
                ),
                SizedBox(height: 16 * h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * w),
                  child: Text(
                    "Recommended Meals",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 16 * h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * w),
                  child: FutureBuilder<List<Food>>(
                    future: _foodsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(40 * h),
                            child: const CircularProgressIndicator(
                              color: AppColors.primarayColor,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading meals',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No meals available',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      final foods = snapshot.data!;
                      return Column(
                        children: List.generate(foods.length, (index) {
                          final food = foods[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == foods.length - 1 ? 0 : 8 * h,
                            ),
                            child: MealTile(food: food, scale: h),
                          );
                        }),
                      );
                    },
                  ),
                ),
                SizedBox(height: kBottomNavigationBarHeight + 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
