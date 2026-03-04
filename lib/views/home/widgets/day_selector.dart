import 'dart:math';
import 'package:flutter/material.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/widgets/home/charts_widget.dart';

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
                bgColor = const Color.fromARGB(
                  111,
                  0,
                  154,
                  205,
                ).withOpacity(0.80);
              } else if (isToday) {
                bgColor = const Color.fromARGB(
                  255,
                  168,
                  168,
                  168,
                ).withOpacity(.15);
              } else {
                bgColor = Colors.white.withOpacity(0);
              }

              final summary = widget.caloriesProgress[dateKey];

              // Calculate macro segments relative to goal
              double proteinPct = 0;
              double carbsPct = 0;
              double fatsPct = 0;

              if (summary != null && summary.calorieGoal > 0) {
                proteinPct = (summary.protein * 4) / summary.calorieGoal;
                carbsPct = (summary.carbs * 4) / summary.calorieGoal;
                fatsPct = (summary.fats * 9) / summary.calorieGoal;
              }

              Color dateColor = isSelected
                  ? Colors.white
                  : isFuture
                  ? Colors.white.withOpacity(0.4)
                  : Colors.white;

              Color labelColor = isSelected
                  ? Colors.white
                  : isFuture
                  ? Colors.grey.withOpacity(0.5)
                  : Colors.grey[350]!;

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
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 14,
                              spreadRadius: 1,
                              offset: const Offset(0, 7), // ظل للأسفل قليلا
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
                            // Background ring
                            CustomPaint(
                              size: Size.infinite,
                              painter: SegmentedRingPainter(
                                protein: 0,
                                carbs: 0,
                                fats: 0,
                                strokeWidth: 3,
                                backgroundColor: isSelected
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.15),
                              ),
                            ),
                            // Macro segments
                            CustomPaint(
                              size: Size.infinite,
                              painter: SegmentedRingPainter(
                                protein: proteinPct.clamp(0.0, 1.0),
                                carbs: carbsPct.clamp(0.0, 1.0),
                                fats: fatsPct.clamp(0.0, 1.0),
                                strokeWidth: 3,
                              ),
                            ),
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
