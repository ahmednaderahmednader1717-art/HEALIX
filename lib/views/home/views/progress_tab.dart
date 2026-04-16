import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/services/nutrition_service.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final NutritionService _nutritionService = NutritionService();

  // ── static / demo data ──────────────────────────────────────────────────────
  int _streakCount = 0;
  final double startWeight = 60.0;
  final double goalWeight = 65.0;
  final double currentWeight = 60.0;
  final DateTime goalDate = DateTime(2026, 3, 31);

  // ── nutrition state ─────────────────────────────────────────────────────────
  DailySummary? _dailySummary;
  MonthlySummary? _monthlySummary;
  bool _nutritionLoading = true;

  // ── selected calendar day ────────────────────────────────────────────────────
  String? _selectedDate; // 'yyyy-MM-dd'

  @override
  void initState() {
    super.initState();
    _loadNutrition();
    // Listen for new food logs to refresh UI instantly
    NutritionService.foodLogged.addListener(_onFoodLogged);
  }

  @override
  void dispose() {
    NutritionService.foodLogged.removeListener(_onFoodLogged);
    super.dispose();
  }

  void _onFoodLogged() {
    if (mounted) {
      _loadNutrition();
    }
  }

  Future<void> _loadNutrition() async {
    setState(() => _nutritionLoading = true);
    // Compute startDate = today - 27 days (to get 28 days including today)
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 27));
    final startDateStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      _nutritionService.getDailySummary(date: _selectedDate),
      _nutritionService.getMonthlySummary(startDate: startDateStr, days: 28),
      _nutritionService.getStreak(),
    ]);

    setState(() {
      _dailySummary = results[0] as DailySummary?;
      _monthlySummary = results[1] as MonthlySummary?;
      final streakInfo = results[2] as StreakInfo?;
      if (streakInfo != null) {
        _streakCount = streakInfo.streakCount;
      }
      _nutritionLoading = false;
    });
  }

  Future<void> _loadDayDetail(String date) async {
    setState(() {
      _selectedDate = date;
      _nutritionLoading = true;
    });
    final summary = await _nutritionService.getDailySummary(date: date);
    setState(() {
      _dailySummary = summary;
      _nutritionLoading = false;
    });
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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

    final double weightProgress = goalWeight == startWeight
        ? 0
        : (currentWeight - startWeight) / (goalWeight - startWeight);
    final int progressPct = (weightProgress * 100).clamp(0, 100).round();

    return RefreshIndicator(
      onRefresh: _loadNutrition,
      color: AppColors.primarayColor,
      backgroundColor: AppColors.ContainerColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          left: 16 * w,
          right: 16 * w,
          top: 80 * h + 10 * h,
          bottom: 120 * h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ───────────────────────────────────────────────────────
            Text(
              'Progress',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 32 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20 * h),

            // ── Streak ──────────────────────────────────────────────────────
            _DayStreakCard(streak: _streakCount, w: w, h: h, scale: scale),
            SizedBox(height: 16 * h),

            // ── Nutrition Donut Chart ────────────────────────────────────────
            _NutritionCard(
              summary: _dailySummary,
              isLoading: _nutritionLoading,
              selectedDate: _selectedDate ?? _todayStr(),
              w: w,
              h: h,
              scale: scale,
            ),
            SizedBox(height: 16 * h),

            // ── 28-day Calendar Strip ────────────────────────────────────────
            _CalendarStripCard(
              monthly: _monthlySummary,
              selectedDate: _selectedDate ?? _todayStr(),
              onDaySelected: (date) {
                if (date == (_selectedDate ?? _todayStr())) return;
                _loadDayDetail(date);
              },
              w: w,
              h: h,
              scale: scale,
            ),
            SizedBox(height: 16 * h),

            // ── Weight Card ──────────────────────────────────────────────────
            _WeightCard(
              currentWeight: currentWeight,
              startWeight: startWeight,
              goalWeight: goalWeight,
              goalDate: goalDate,
              w: w,
              h: h,
              scale: scale,
            ),
            SizedBox(height: 16 * h),

            // ── Weight Progress Chart ────────────────────────────────────────
            _WeightProgressCard(
              progressPct: progressPct,
              currentWeight: currentWeight,
              startWeight: startWeight,
              goalWeight: goalWeight,
              w: w,
              h: h,
              scale: scale,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Donut Chart Card
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionCard extends StatelessWidget {
  const _NutritionCard({
    required this.summary,
    required this.isLoading,
    required this.selectedDate,
    required this.w,
    required this.h,
    required this.scale,
  });

  final DailySummary? summary;
  final bool isLoading;
  final String selectedDate;
  final double w, h, scale;

  String _friendlyDate(String isoDate) {
    try {
      final parts = isoDate.split('-');
      if (parts.length < 3) return isoDate;
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final today = DateTime.now();
      if (dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day)
        return "Today's Nutrition";
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final totalCals = s?.totalCalories ?? 0;
    final goalCals = s?.calorieGoal ?? 0;
    final remaining = s?.remainingCalories ?? 0;
    final protein = s?.totalProtein ?? 0;
    final carbs = s?.totalCarbs ?? 0;
    final fats = s?.totalFats ?? 0;

    final proteinPct = s?.proteinPercent ?? 0;
    final carbsPct = s?.carbsPercent ?? 0;
    final fatsPct = s?.fatsPercent ?? 0;

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _friendlyDate(selectedDate),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 16 * scale,
                  height: 16 * scale,
                  child: const CircularProgressIndicator(
                    color: AppColors.primarayColor,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16 * h),

          // Donut + stats side-by-side
          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 140 * scale,
                height: 140 * scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(140 * scale, 140 * scale),
                      painter: _DonutPainter(
                        proteinPct: proteinPct,
                        carbsPct: carbsPct,
                        fatsPct: fatsPct,
                        isEmpty: totalCals == 0,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalCals.toStringAsFixed(0),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11 * scale,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20 * w),

              // Stats column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _macroRow(
                      'Protein',
                      protein,
                      proteinPct,
                      Colors.redAccent,
                      scale,
                      h,
                    ),
                    SizedBox(height: 10 * h),
                    _macroRow(
                      'Carbs',
                      carbs,
                      carbsPct,
                      Colors.amberAccent,
                      scale,
                      h,
                    ),
                    SizedBox(height: 10 * h),
                    _macroRow(
                      'Fats',
                      fats,
                      fatsPct,
                      Colors.blueAccent,
                      scale,
                      h,
                    ),
                    SizedBox(height: 14 * h),
                    Divider(color: Colors.white12, height: 1),
                    SizedBox(height: 10 * h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Goal',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12 * scale,
                          ),
                        ),
                        Text(
                          '${goalCals.toStringAsFixed(0)} kcal',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12 * scale,
                          ),
                        ),
                        Text(
                          '${remaining.toStringAsFixed(0)} kcal',
                          style: GoogleFonts.inter(
                            color: remaining >= 0
                                ? AppColors.primarayColor
                                : Colors.redAccent,
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Today's log list
          if (s != null && s.logs.isNotEmpty) ...[
            SizedBox(height: 16 * h),
            Divider(color: Colors.white12, height: 1),
            SizedBox(height: 12 * h),
            Text(
              'Logged Today',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8 * h),
            ...s.logs.map(
              (log) => Padding(
                padding: EdgeInsets.only(bottom: 6 * h),
                child: Row(
                  children: [
                    if (log.imageUrl != null && log.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6 * scale),
                        child: (log.imageUrl!.startsWith('http') || log.imageUrl!.startsWith('https'))
                            ? Image.network(
                                log.imageUrl!,
                                width: 24 * scale,
                                height: 24 * scale,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, st) => Icon(Icons.restaurant_rounded, color: AppColors.primarayColor, size: 14 * scale),
                              )
                            : Image.file(
                                File(log.imageUrl!),
                                width: 24 * scale,
                                height: 24 * scale,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, st) => Icon(Icons.restaurant_rounded, color: AppColors.primarayColor, size: 14 * scale),
                              ),
                      )
                    else
                      Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primarayColor,
                        size: 14 * scale,
                      ),
                    SizedBox(width: 8 * w),
                    Expanded(
                      child: Text(
                        log.foodName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13 * scale,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${log.calories.toStringAsFixed(0)} kcal',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroRow(
    String label,
    double grams,
    double pct,
    Color color,
    double scale,
    double h,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12 * scale,
                  ),
                ),
              ],
            ),
            Text(
              '${grams.toStringAsFixed(1)}g',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4 * scale,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut Chart Painter
// ─────────────────────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatsPct,
    required this.isEmpty,
  });

  final double proteinPct, carbsPct, fatsPct;
  final bool isEmpty;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const strokeW = 14.0;
    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: r - strokeW / 2,
    );

    if (isEmpty) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi,
        false,
        Paint()
          ..color = Colors.white12
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
      return;
    }

    const gap = 0.04; // radians gap between arcs
    final segments = [
      (proteinPct, Colors.redAccent),
      (carbsPct, Colors.amberAccent),
      (fatsPct, Colors.blueAccent),
    ];

    double startAngle = -pi / 2;
    for (final (pct, color) in segments) {
      final sweep = (2 * pi * pct) - gap;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          startAngle,
          sweep,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW
            ..strokeCap = StrokeCap.round,
        );
      }
      startAngle += 2 * pi * pct;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.proteinPct != proteinPct ||
      old.carbsPct != carbsPct ||
      old.fatsPct != fatsPct;
}

// ─────────────────────────────────────────────────────────────────────────────
// 28-Day Calendar Strip Card
// ─────────────────────────────────────────────────────────────────────────────
class _CalendarStripCard extends StatelessWidget {
  const _CalendarStripCard({
    required this.monthly,
    required this.selectedDate,
    required this.onDaySelected,
    required this.w,
    required this.h,
    required this.scale,
  });

  final MonthlySummary? monthly;
  final String selectedDate;
  final void Function(String date) onDaySelected;
  final double w, h, scale;

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // Build a map of date → DaySummary from the API data
    final Map<String, DaySummary> dayMap = {};
    if (monthly != null) {
      for (final d in monthly!.days) {
        dayMap[d.date] = d;
      }
    }

    // Generate last 28 days (oldest first)
    final today = DateTime.now();
    final days = List.generate(28, (i) {
      return today.subtract(Duration(days: 27 - i));
    });

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 28 Days',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4 * h),

          // Legend
          Row(
            children: [
              _legendDot(AppColors.primarayColor, 'Goal reached', scale),
              SizedBox(width: 12 * w),
              _legendDot(Colors.orange, 'Logged', scale),
              SizedBox(width: 12 * w),
              _legendDot(Colors.white12, 'No data', scale),
            ],
          ),
          SizedBox(height: 12 * h),

          // Day-of-week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return SizedBox(
                width: 36 * scale,
                child: Center(
                  child: Text(
                    _dayLabels[i],
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 6 * h),

          // Grid — pad to align first day to correct weekday
          _buildGrid(days, dayMap, scale, h),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<DateTime> days,
    Map<String, DaySummary> dayMap,
    double scale,
    double h,
  ) {
    // Determine the weekday offset of the first day (0 = Sunday)
    final firstWeekday =
        days.first.weekday % 7; // DateTime: Mon=1..Sun=7 → Sun=0
    final totalCells = firstWeekday + days.length;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6 * h,
        crossAxisSpacing: 4 * w,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayIndex = index - firstWeekday;
        if (dayIndex < 0 || dayIndex >= days.length) {
          return const SizedBox.shrink();
        }
        final date = days[dayIndex];
        final dateStr = _fmt(date);
        final daySummary = dayMap[dateStr];
        final isSelected = dateStr == selectedDate;
        final isToday = dateStr == _fmt(DateTime.now());

        Color dotColor;
        if (daySummary == null || !daySummary.hasData) {
          dotColor = Colors.white12;
        } else if (daySummary.goalAchieved) {
          dotColor = AppColors.primarayColor;
        } else {
          dotColor = Colors.orange;
        }

        return GestureDetector(
          onTap: () => onDaySelected(dateStr),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28 * scale,
                height: 28 * scale,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: isSelected || isToday
                      ? Border.all(
                          color: isSelected
                              ? Colors.white
                              : AppColors.primarayColor,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: GoogleFonts.inter(
                      color: dotColor == Colors.white12
                          ? Colors.white38
                          : Colors.white,
                      fontSize: 10 * scale,
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String label, double scale) {
    return Row(
      children: [
        Container(
          width: 8 * scale,
          height: 8 * scale,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4 * scale),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 10 * scale),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Streak Card
// ─────────────────────────────────────────────────────────────────────────────
class _DayStreakCard extends StatelessWidget {
  const _DayStreakCard({
    required this.streak,
    required this.w,
    required this.h,
    required this.scale,
  });

  final int streak;
  final double w, h, scale;

  @override
  Widget build(BuildContext context) {
    final int prevDay = streak > 0 ? streak - 1 : 0;
    final int nextDay = streak + 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * w, vertical: 16 * h),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Streak',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12 * h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '🔥',
                style: TextStyle(
                  fontSize: 30 * scale,
                  color: Colors.orange.withOpacity(0.55),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * w),
                  child: Container(
                    height: 7 * h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB84500),
                          Color(0xFFFF8C00),
                          Color(0xFFFFB300),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Text('🔥', style: TextStyle(fontSize: 40 * scale)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * w),
                  child: Container(
                    height: 7 * h,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: Text('🔥', style: TextStyle(fontSize: 30 * scale)),
              ),
            ],
          ),
          SizedBox(height: 6 * h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $prevDay',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 11 * scale,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * w,
                  vertical: 3 * h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Text(
                  'Day $streak',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Day $nextDay',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 11 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current Weight Card
// ─────────────────────────────────────────────────────────────────────────────
class _WeightCard extends StatelessWidget {
  const _WeightCard({
    required this.currentWeight,
    required this.startWeight,
    required this.goalWeight,
    required this.goalDate,
    required this.w,
    required this.h,
    required this.scale,
  });

  final double currentWeight, startWeight, goalWeight;
  final DateTime goalDate;
  final double w, h, scale;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${months[goalDate.month - 1]} ${goalDate.day}, ${goalDate.year}';

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weight',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 13 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * h),
                  Text(
                    '${currentWeight.toStringAsFixed(currentWeight == currentWeight.roundToDouble() ? 0 : 1)} kg',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * w,
                    vertical: 10 * h,
                  ),
                ),
                child: Text(
                  'Log weight →',
                  style: GoogleFonts.inter(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * h),
          Container(height: 1, color: Colors.grey[800]),
          SizedBox(height: 12 * h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 13 * scale,
                  ),
                  children: [
                    const TextSpan(text: 'Start: '),
                    TextSpan(
                      text: '${startWeight.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 13 * scale,
                  ),
                  children: [
                    const TextSpan(text: 'Goal: '),
                    TextSpan(
                      text: '${goalWeight.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * h),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 13 * scale,
              ),
              children: [
                const TextSpan(text: 'At your goal by '),
                TextSpan(
                  text: '$dateStr.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weight Progress Chart Card
// ─────────────────────────────────────────────────────────────────────────────
class _WeightProgressCard extends StatelessWidget {
  const _WeightProgressCard({
    required this.progressPct,
    required this.currentWeight,
    required this.startWeight,
    required this.goalWeight,
    required this.w,
    required this.h,
    required this.scale,
  });

  final int progressPct;
  final double currentWeight, startWeight, goalWeight;
  final double w, h, scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight Progress',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Colors.grey[400],
                    size: 16 * scale,
                  ),
                  SizedBox(width: 4 * w),
                  Text(
                    '$progressPct% of goal',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 13 * scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * h),
          SizedBox(
            height: 200 * h,
            child: _WeightLineChart(
              currentWeight: currentWeight,
              startWeight: startWeight,
              goalWeight: goalWeight,
              scale: scale,
              h: h,
              w: w,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weight Line Chart
// ─────────────────────────────────────────────────────────────────────────────
class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({
    required this.currentWeight,
    required this.startWeight,
    required this.goalWeight,
    required this.scale,
    required this.h,
    required this.w,
  });

  final double currentWeight, startWeight, goalWeight;
  final double scale, h, w;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        currentWeight: currentWeight,
        startWeight: startWeight,
        goalWeight: goalWeight,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.currentWeight,
    required this.startWeight,
    required this.goalWeight,
  });

  final double currentWeight, startWeight, goalWeight;

  @override
  void paint(Canvas canvas, Size size) {
    const labelW = 32.0;
    const padding = 8.0;
    final chartLeft = labelW + padding;
    final chartRight = size.width;
    final chartBottom = size.height;

    final minY = (currentWeight - 4).floorToDouble();
    final maxY = (currentWeight + 4).ceilToDouble();
    final yRange = maxY - minY;

    double toY(double val) =>
        chartBottom - ((val - minY) / yRange) * chartBottom;

    final gridPaint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..strokeWidth = 1;

    const labelStyle = TextStyle(color: Color(0xFF8E8E93), fontSize: 11);

    for (double val = minY; val <= maxY; val += 2) {
      final y = toY(val);
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(0), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = toY(currentWeight);
    canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), linePaint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(chartLeft, y), 4, dotPaint);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// END OF FILE
