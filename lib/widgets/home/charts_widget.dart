import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

// كرت حلقة أبـِل متجاوب مع جميع الأحجام
class AppleRingCard extends StatefulWidget {
  final String title;
  final double value;
  final Color color;
  final double scale;

  const AppleRingCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.scale = 1.0,
  });

  @override
  State<AppleRingCard> createState() => _AppleRingCardState();
}

class _AppleRingCardState extends State<AppleRingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AppleRingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final internalScale = (cardWidth / 180).clamp(0.75, 1.1);

        final ringDiameter = cardWidth * (0.80 * internalScale);
        final ringStroke = 20.0;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(22 * widget.scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(15 * widget.scale),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(
                      ringDiameter,
                      cardHeight * (0.40 * internalScale),
                    ),
                    painter: AppleBottomLabelRingPainter(
                      context: context,
                      progress: _animation.value,
                      color: widget.color,
                      strokeWidth: ringStroke,
                    ),
                  );
                },
              ),
              SizedBox(height: cardHeight * 0.012),
              Column(
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.inriaSans(
                      color: colorScheme.onSurface,
                      fontSize: cardHeight * 0.080 * internalScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.005),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) => Text(
                      "${(_animation.value * 100).toInt()}%",
                      style: GoogleFonts.inriaSans(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: cardHeight * 0.085 * internalScale,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class UnifiedMacroChart extends StatefulWidget {
  final double caloriesEaten;
  final double calorieGoal;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final double scale;

  const UnifiedMacroChart({
    super.key,
    required this.caloriesEaten,
    required this.calorieGoal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    this.scale = 1.0,
  });

  @override
  State<UnifiedMacroChart> createState() => _UnifiedMacroChartState();
}

class _UnifiedMacroChartState extends State<UnifiedMacroChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showGrams = true; // Toggle state

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(UnifiedMacroChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proteinGrams != widget.proteinGrams ||
        oldWidget.carbsGrams != widget.carbsGrams ||
        oldWidget.fatsGrams != widget.fatsGrams ||
        oldWidget.caloriesEaten != widget.caloriesEaten) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Compute ring proportions from grams eaten.
    // Calorie contribution: protein=4 kcal/g, carbs=4 kcal/g, fats=9 kcal/g
    final proteinKcal = widget.proteinGrams * 4;
    final carbsKcal = widget.carbsGrams * 4;
    final fatsKcal = widget.fatsGrams * 9;
    final totalMacroKcal = proteinKcal + carbsKcal + fatsKcal;

    final proteinPct = totalMacroKcal > 0 ? proteinKcal / totalMacroKcal : 0.0;
    final carbsPct = totalMacroKcal > 0 ? carbsKcal / totalMacroKcal : 0.0;
    final fatsPct = totalMacroKcal > 0 ? fatsKcal / totalMacroKcal : 0.0;

    // Overall calorie progress relative to goal (0.0 to 1.0)
    final overallProgress = widget.calorieGoal > 0
        ? (widget.caloriesEaten / widget.calorieGoal).clamp(0.0, 1.0)
        : 0.0;

    final goalStr = widget.calorieGoal > 0
        ? widget.calorieGoal.toStringAsFixed(0)
        : '—';

    return GestureDetector(
      onTap: () {
        setState(() {
          _showGrams = !_showGrams;
        });
      },
      child: Container(
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: theme.brightness == Brightness.dark ? 0.69 : 0.8),
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Calories",
              style: GoogleFonts.inter(
                color: colorScheme.onSurface,
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(15 * scale),
            Row(
              children: [
                const Spacer(flex: 1),
                // Left Side: Segmented Ring
                Expanded(
                  flex: 5,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: SegmentedRingPainter(
                                context: context,
                                protein:
                                    proteinPct *
                                    overallProgress *
                                    _animation.value,
                                carbs:
                                    carbsPct *
                                    overallProgress *
                                    _animation.value,
                                fats:
                                    fatsPct *
                                    overallProgress *
                                    _animation.value,
                                strokeWidth: 20 * scale,
                              ),
                            );
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                final shown =
                                    (widget.caloriesEaten * _animation.value)
                                        .toInt();
                                return Text(
                                  '$shown',
                                  style: GoogleFonts.inter(
                                    color: colorScheme.onSurface,
                                    fontSize: 22 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            Text(
                              '/ $goalStr kcal',
                              style: GoogleFonts.inter(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10 * scale,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(30 * scale),
                // Right Side: Labels with grams or percentages (relative to Goal)
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMacroLabel(
                        context,
                        "Fats",
                        _showGrams
                            ? widget.fatsGrams
                            : (widget.calorieGoal > 0
                                  ? (fatsKcal / widget.calorieGoal * 100)
                                  : 0.0),
                        _showGrams ? 'g' : '%',
                        Colors.blueAccent,
                        scale,
                      ),
                      Gap(16 * scale),
                      _buildMacroLabel(
                        context,
                        "Protein",
                        _showGrams
                            ? widget.proteinGrams
                            : (widget.calorieGoal > 0
                                  ? (proteinKcal / widget.calorieGoal * 100)
                                  : 0.0),
                        _showGrams ? 'g' : '%',
                        Colors.redAccent,
                        scale,
                      ),
                      Gap(16 * scale),
                      _buildMacroLabel(
                        context,
                        "Carbs",
                        _showGrams
                            ? widget.carbsGrams
                            : (widget.calorieGoal > 0
                                  ? (carbsKcal / widget.calorieGoal * 100)
                                  : 0.0),
                        _showGrams ? 'g' : '%',
                        Colors.amberAccent,
                        scale,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLabel(
    BuildContext context,
    String label,
    double value,
    String unit,
    Color color,
    double scale,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12 * scale,
          height: 12 * scale,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        Gap(10 * scale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: colorScheme.onSurface,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                color: color,
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
              ),
              child: Text(
                '${value.toStringAsFixed(unit == '%' ? 0 : 1)} $unit',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SegmentedRingPainter extends CustomPainter {
  final BuildContext context;
  final double protein;
  final double carbs;
  final double fats;
  final double strokeWidth;
  final Color? backgroundColor;
  final double? genericProgress;
  final Color? genericColor;

  SegmentedRingPainter({
    required this.context,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.strokeWidth,
    this.backgroundColor,
    this.genericProgress,
    this.genericColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colorScheme = Theme.of(context).colorScheme;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = backgroundColor ?? colorScheme.onSurface.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background ring
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -pi / 2;

    if (genericProgress != null && genericProgress! > 0) {
      _drawSegment(
        canvas,
        rect,
        startAngle,
        genericProgress!,
        genericColor ?? AppColors.primarayColor,
      );
      return;
    }

    _drawSegment(canvas, rect, startAngle, fats, Colors.blueAccent);
    startAngle += (fats * 2 * pi);

    _drawSegment(canvas, rect, startAngle, protein, Colors.redAccent);
    startAngle += (protein * 2 * pi);

    _drawSegment(canvas, rect, startAngle, carbs, Colors.amberAccent);
  }

  void _drawSegment(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double percent,
    Color color,
  ) {
    if (percent <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Add a subtle glow to the segment
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final sweepAngle = percent * 2 * pi;

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// رسمة الحلقة السفلية مع اللـabel، متجاوبة مع كل الأحجام
class AppleBottomLabelRingPainter extends CustomPainter {
  final BuildContext context;
  final double progress;
  final Color color;
  final double strokeWidth;

  AppleBottomLabelRingPainter({
    required this.context,
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colorScheme = Theme.of(context).colorScheme;
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    const totalAngle = 4 * pi / 3;

    final backgroundPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + (pi - totalAngle) / 2,
      totalAngle,
      false,
      backgroundPaint,
    );

    final gradient = SweepGradient(
      startAngle: pi + (pi - totalAngle) / 2,
      endAngle: pi + (pi - totalAngle) / 2 + totalAngle,
      colors: [color.withValues(alpha: 0.7), color, color.withValues(alpha: 0.9)],
      stops: const [0.0, 0.6, 1.0],
    );

    final ringPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweepFilled = totalAngle * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + (pi - totalAngle) / 2,
      sweepFilled,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + (pi - totalAngle) / 2,
      sweepFilled,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
