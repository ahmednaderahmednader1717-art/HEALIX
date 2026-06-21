import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:test_splash/models/nutrition_models.dart';

class DaySelector extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final int totalDays;
  final Map<DateTime, DaySummary>
  caloriesProgress; // نسبة الإنجاز لكل يوم (من 0.0 إلى 1.0)

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.caloriesProgress,
    this.totalDays = 35,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late int weeksCount;
  late List<List<DateTime>> weeks;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    const int daysPerWeek = 7;
    int weekForToday = 3;
    int todayIndex = (weekForToday + 1) * daysPerWeek - 1;
    DateTime lastDay = DateTime.now();
    DateTime firstDay = lastDay.subtract(Duration(days: todayIndex));

    List<DateTime> days = List.generate(
      widget.totalDays,
      (i) => firstDay.add(Duration(days: i)),
    );
    weeksCount = (days.length / daysPerWeek).ceil();
    weeks = List.generate(
      weeksCount,
      (i) => days.skip(i * daysPerWeek).take(daysPerWeek).toList(),
    );

    int initialWeek = weekForToday < weeksCount ? weekForToday : weeksCount - 1;
    _pageController = PageController(initialPage: initialWeek);
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 105 * h,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        itemCount: weeksCount,
        itemBuilder: (context, weekIndex) {
          final week = weeks[weekIndex];
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: week.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 8 * w),
            itemBuilder: (context, dayIndex) {
              final day = week[dayIndex];
              final dateKey = DateTime(day.year, day.month, day.day);
              final isSelected =
                  day.day == widget.selectedDay.day &&
                  day.month == widget.selectedDay.month &&
                  day.year == widget.selectedDay.year;
              final now = DateTime.now();
              final isToday =
                  day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              final isFuture = day.isAfter(now);

              // Background colors
              Color bgColor;
              if (isSelected) {
                bgColor = colorScheme.primary.withValues(alpha: 0.8);
              } else if (isToday) {
                bgColor = colorScheme.onSurface.withValues(alpha: 0.15);
              } else {
                bgColor = Colors.transparent;
              }

              final summary = widget.caloriesProgress[dateKey];

              // Fallback goal: if current day summary has 0 goal, try to find any valid goal in the map
              double effectiveGoal = summary?.calorieGoal ?? 0;
              if (effectiveGoal <= 0) {
                for (var daySummary in widget.caloriesProgress.values) {
                  if (daySummary.calorieGoal > 0) {
                    effectiveGoal = daySummary.calorieGoal;
                    break;
                  }
                }
              }

              Widget ringWidget;
              bool hasMeals = summary != null && summary.totalCalories > 0;
              if (!hasMeals) {
                ringWidget = DottedBorder(
                  borderType: BorderType.Circle,
                  color: isSelected
                      ? colorScheme.onPrimary.withValues(alpha: 0.5)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  strokeWidth: 2.0,
                  dashPattern: const [4, 4],
                  padding: EdgeInsets.zero,
                  child: const SizedBox.expand(),
                );
              } else {
                double caloriesEaten = summary.totalCalories;
                double caloriesLeft = effectiveGoal - caloriesEaten;
                Color ringColor;
                if (caloriesLeft > 200) {
                  ringColor = Colors.red; // Red
                } else if (caloriesLeft > 100) {
                  ringColor = Colors.amber; // Yellow
                } else {
                  ringColor = const Color(0xFF4CD964); // Professional Green
                }

                double progress = effectiveGoal > 0
                    ? (caloriesEaten / effectiveGoal).clamp(0.0, 1.0)
                    : 0.0;
                ringWidget = SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    color: ringColor,
                    backgroundColor: isSelected
                        ? colorScheme.onPrimary.withValues(alpha: 0.3)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                    strokeCap: StrokeCap.round,
                  ),
                );
              }

              Color dateColor = isSelected
                  ? colorScheme.onPrimary
                  : isFuture
                  ? colorScheme.onSurface.withValues(alpha: 0.4)
                  : colorScheme.onSurface;

              Color labelColor = isSelected
                  ? colorScheme.onPrimary
                  : isFuture
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : colorScheme.onSurfaceVariant;

              return GestureDetector(
                onTap: () => widget.onDaySelected(day),
                child: Container(
                  width: 57 * w,
                  height: 62 * h,
                  margin: EdgeInsets.symmetric(horizontal: 1, vertical: 6 * h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 14,
                              spreadRadius: 1,
                              offset: const Offset(0, 7),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(day),
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14 * scale,
                        ),
                      ),
                      SizedBox(height: 7 * h),
                      SizedBox(
                        width: 40 * scale,
                        height: 40 * scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ringWidget,
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: dateColor,
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getDayName(DateTime d) {
    switch (d.weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }
}
