import 'package:flutter/material.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/widgets/home/charts_widget.dart';
import 'package:test_splash/views/home/widgets/health_extra_metrics.dart';
import 'package:gap/gap.dart';

class HealthMetricsPager extends StatefulWidget {
  final double scale;
  final AsyncSnapshot<DailySummary?> snapshot;
  final ValueChanged<int>? onPageChanged;

  const HealthMetricsPager({
    super.key,
    required this.scale,
    required this.snapshot,
    this.onPageChanged,
  });

  @override
  State<HealthMetricsPager> createState() => _HealthMetricsPagerState();
}

class _HealthMetricsPagerState extends State<HealthMetricsPager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final summary = widget.snapshot.data;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 270 * scale, // Matched height exactly to MacroChart
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              widget.onPageChanged?.call(index);
            },
            children: [
              // Page 0: Original Macro Chart
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: UnifiedMacroChart(
                  caloriesEaten: summary?.totalCalories ?? 0,
                  calorieGoal: summary?.calorieGoal ?? 0,
                  proteinGrams: summary?.totalProtein ?? 0,
                  carbsGrams: summary?.totalCarbs ?? 0,
                  fatsGrams: summary?.totalFats ?? 0,
                  scale: scale,
                ),
              ),
              
              // Page 1: Extra Metrics (Steps, Calories Burned, Water)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: HealthExtraMetrics(scale: scale),
              ),
            ],
          ),
        ),
        Gap(12 * scale),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4 * scale),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
