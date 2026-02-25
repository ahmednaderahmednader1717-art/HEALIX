import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  // ── demo data ──────────────────────────────────────────────────────────────
  final int dayStreak = 0;
  final int badgesEarned = 4;
  final double startWeight = 60.0;
  final double goalWeight = 65.0;
  final double currentWeight = 60.0;
  final DateTime goalDate = DateTime(2026, 3, 31);

  // Badge emoji colours (decorative)
  final List<Color> badgeColors = const [
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
  ];

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

    final double weightProgress = goalWeight == startWeight
        ? 0
        : (currentWeight - startWeight) / (goalWeight - startWeight);
    final int progressPct = (weightProgress * 100).clamp(0, 100).round();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16 * w,
        right: 16 * w,
        top: toolbarHeight + 10 * h,
        bottom: 120 * h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ───────────────────────────────────────────────────────────
          Text(
            'Progress',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20 * h),

          // ── Top row: Day Streak + Badges ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DayStreakCard(
                  streak: dayStreak,
                  w: w,
                  h: h,
                  scale: scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * h),

          // ── Current Weight card ─────────────────────────────────────────────
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

          // ── Weight Progress chart ───────────────────────────────────────────
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
          // Title
          Text(
            'Streak',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12 * h),
          // ── Flames row (bars centred on the emoji) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Previous day flame
              Text(
                '🔥',
                style: TextStyle(
                  fontSize: 30 * scale,
                  color: Colors.orange.withOpacity(0.55),
                ),
              ),
              // Orange connector bar
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
              // Current day flame (larger)
              Text('🔥', style: TextStyle(fontSize: 40 * scale)),
              // Gray connector bar
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
              // Next day flame (greyscale)
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
          // ── Labels row ──
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
// Badges Card
// ─────────────────────────────────────────────────────────────────────────────

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
    final months = [
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
          // Header row
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
              // Log weight button
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: StadiumBorder(),
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
          // Divider
          Container(height: 1, color: Colors.grey[800]),
          SizedBox(height: 12 * h),
          // Start / Goal row
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
          // Chart title row
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
          // Chart
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
// Simple line chart widget
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

    // Y axis range: 4 units below & above current weight
    final minY = (currentWeight - 4).floorToDouble();
    final maxY = (currentWeight + 4).ceilToDouble();
    final yRange = maxY - minY;

    double toY(double val) =>
        chartBottom - ((val - minY) / yRange) * chartBottom;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..strokeWidth = 1;

    final labelStyle = const TextStyle(color: Color(0xFF8E8E93), fontSize: 11);

    for (double val = minY; val <= maxY; val += 2) {
      final y = toY(val);
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
      // Label
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(0), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Horizontal line at current weight
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = toY(currentWeight);
    canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), linePaint);

    // Dot at start
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(chartLeft, y), 4, dotPaint);
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Heptagon painter for badge icon
// ─────────────────────────────────────────────────────────────────────────────
class _HeptagonPainter extends CustomPainter {
  _HeptagonPainter({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final Color fillColor, strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const int sides = 7;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - strokeWidth;
    final startAngle = -pi / 2;

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + (2 * pi / sides) * i;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_HeptagonPainter old) => false;
}
