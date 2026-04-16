import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:test_splash/views/home/widgets/day_selector.dart';
import 'package:test_splash/views/home/widgets/meal_tile.dart';
import 'package:test_splash/views/home/widgets/row_header.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/home/widgets/health_metrics_pager.dart';
import 'package:test_splash/models/food_model.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/services/food_service.dart';
import 'package:test_splash/services/auth_service.dart';
import 'package:test_splash/services/nutrition_service.dart';
import 'package:test_splash/services/notification_service.dart';
import 'package:test_splash/services/live_activity_service.dart';

class HomeTab extends StatefulWidget {
  final void Function(int)? onTabChange;

  const HomeTab({super.key, this.onTabChange});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime selectedDay = DateTime.now();
  late Future<List<Food>> _foodsFuture;
  Future<DailySummary?>? _dailySummaryFuture;
  final NutritionService _nutritionService = NutritionService();
  Map<DateTime, DaySummary> _monthlyProgress = {};
  int _streakCount = 0;
  int _pagerPage = 0;

  @override
  void initState() {
    super.initState();
    _foodsFuture = _fetchProcessedFoods();
    _refreshAllData();
    NutritionService.foodLogged.addListener(_onFoodLogged);
  }

  void _onFoodLogged() {
    setState(() {
      selectedDay = DateTime.now();
    });
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    // 0. Sync any pending offline standard DB logs
    _nutritionService.syncPendingLogs();

    // 1. Fetch monthly summary for the broad 35-day range
    await _fetchMonthlySummary();

    // 2. Proactively fetch the last 7 days of daily summaries to ensure accuracy
    // This fixes the issue where monthly summary might miss data for recent days.
    final today = DateTime.now();
    final List<Future> dailyFetches = [];
    for (int i = 0; i < 7; i++) {
      dailyFetches.add(_fetchDailySummary(today.subtract(Duration(days: i))));
    }

    await Future.wait(dailyFetches);

    // 3. Ensure selected day is also refreshed (already included in loop above if selectedDay is recent)
    if (selectedDay.isBefore(today.subtract(const Duration(days: 6)))) {
      await _fetchDailySummary(selectedDay);
    }

    // 4. Fetch the current streak
    await _fetchStreak();

    // 5. Update streak reminder

    final todayKey = DateTime(today.year, today.month, today.day);
    final hasLoggedToday = _monthlyProgress[todayKey]?.hasData ?? false;
    LocalNotificationService.updateStreakReminder(hasLoggedToday);
  }

  Future<void> _fetchStreak() async {
    final streak = await _nutritionService.getStreak();
    if (streak != null && mounted) {
      setState(() {
        _streakCount = streak.streakCount;
      });
    }
  }

  Future<void> _fetchDailySummary(DateTime date) async {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final summary = await _nutritionService.getDailySummary(date: dateStr);

    if (summary != null && mounted) {
      final dateKey = DateTime(date.year, date.month, date.day);
      setState(() {
        _monthlyProgress[dateKey] = DaySummary(
          date: summary.date,
          totalCalories: summary.totalCalories,
          calorieGoal: summary.calorieGoal,
          protein: summary.totalProtein,
          carbs: summary.totalCarbs,
          fats: summary.totalFats,
          goalAchieved:
              summary.calorieGoal > 0 &&
              summary.totalCalories >= summary.calorieGoal,
          hasData: summary.logs.isNotEmpty || summary.totalCalories > 0,
        );
        // If we have a valid goal now, apply it to other days with 0 goal
        if (summary.calorieGoal > 0) {
          _monthlyProgress.updateAll((key, day) {
            if (day.calorieGoal == 0) {
              return DaySummary(
                date: day.date,
                totalCalories: day.totalCalories,
                calorieGoal: summary.calorieGoal,
                protein: day.protein,
                carbs: day.carbs,
                fats: day.fats,
                goalAchieved: day.goalAchieved,
                hasData: day.hasData,
              );
            }
            return day;
          });
        }
      });
    }

    // Update the future specifically for the chart widget if it matches the current selection
    final selectedDayKey = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final currentFetchKey = DateTime(date.year, date.month, date.day);
    if (selectedDayKey == currentFetchKey) {
      setState(() {
        _dailySummaryFuture = Future.value(summary);
      });

      // Update Live Activity if it's today
      if (summary != null) {
        print("======== LIVE ACTIVITY DEBUG: SUMMARY FETCHED ========");
        final now = DateTime.now();
        if (currentFetchKey.year == now.year &&
            currentFetchKey.month == now.month &&
            currentFetchKey.day == now.day) {
          print("======== LIVE ACTIVITY DEBUG: DATE MATCH (TODAY) ========");
          SharedPreferences.getInstance().then((prefs) {
            final bool isLiveActivityEnabled =
                prefs.getBool('live_activities_enabled') ?? true;

            print(
              "======== LIVE ACTIVITY DEBUG: ENABLED FLAG = $isLiveActivityEnabled ========",
            );

            // FORCE TRIGGER FOR DEBUGGING
            if (isLiveActivityEnabled || true) {
              final double calGoal = summary.calorieGoal;
              final double pGoal = summary.proteinGoal;
              final double cGoal = summary.carbsGoal;
              final double fGoal = summary.fatsGoal;

              print(
                "======== LIVE ACTIVITY DEBUG: CALLING updateActivity() cal=$calGoal p=$pGoal c=$cGoal f=$fGoal ========",
              );

              LiveActivityService.updateActivity(
                caloriesLeft: (calGoal - summary.totalCalories).clamp(
                  0,
                  double.infinity,
                ),
                proteinLeft: (pGoal - summary.totalProtein).clamp(
                  0,
                  double.infinity,
                ),
                carbsLeft: (cGoal - summary.totalCarbs).clamp(
                  0,
                  double.infinity,
                ),
                fatsLeft: (fGoal - summary.totalFats).clamp(0, double.infinity),
              );
            }
          });
        }
      }
    }
  }

  Future<void> _fetchMonthlySummary() async {
    // Match DaySelector logic: 35 days starting from (today - 27 days)
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 27));
    final startDateStr =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

    final summary = await _nutritionService.getMonthlySummary(
      startDate: startDateStr,
      days: 35,
    );
    if (summary != null) {
      if (mounted) {
        setState(() {
          for (var day in summary.days) {
            try {
              final dt = DateTime.parse(day.date);
              final dateKey = DateTime(dt.year, dt.month, dt.day);
              // Only add if not already present or if we want to refresh
              // (but don't overwrite days we might have fetched explicitly with more detail)
              if (!_monthlyProgress.containsKey(dateKey) ||
                  _monthlyProgress[dateKey]!.calorieGoal == 0) {
                _monthlyProgress[dateKey] = day;
              }
            } catch (_) {}
          }
        });
      }
    }
  }

  @override
  void dispose() {
    NutritionService.foodLogged.removeListener(_onFoodLogged);
    super.dispose();
  }

  Future<List<Food>> _fetchProcessedFoods() async {
    final foods = await FoodService().getFoods();
    if (foods.isEmpty) return [];
    return (foods..shuffle()).take(4).toList();
  }

  void onDaySelected(DateTime day) {
    setState(() {
      selectedDay = day;
    });
    _fetchDailySummary(day);
  }

  Future<void> _onRefresh() async {
    await AuthService().refreshToken();
    _foodsFuture = _fetchProcessedFoods();
    _fetchDailySummary(selectedDay);
    _fetchMonthlySummary();
    await _foodsFuture;
  }

  String _getNutritionHeader() {
    if (_pagerPage == 1) return "Today's Activity";
    final now = DateTime.now();
    final isToday =
        selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;
    return isToday
        ? "Today's Total Nutrition"
        : "Nutrition for ${DateFormat('EEE, MMM d').format(selectedDay)}";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const baseWidth = 430.0;
    const baseHeight = 932.0;

    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = math.min(w, h);

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
                              "$_streakCount",
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
                  caloriesProgress: _monthlyProgress,
                ),

                SizedBox(height: 8 * h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * w),
                  child: RowHeader(
                    title: _getNutritionHeader(),
                    actionText: "",
                    onAction: null,
                    scale: w,
                  ),
                ),
                SizedBox(height: 12 * h),
                FutureBuilder<DailySummary?>(
                  future: _dailySummaryFuture,
                  builder: (context, snapshot) {
                    return HealthMetricsPager(
                      scale: scale,
                      snapshot: snapshot,
                      onPageChanged: (page) {
                        setState(() => _pagerPage = page);
                      },
                    );
                  },
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
