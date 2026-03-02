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
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final internalScale = (cardWidth / 180).clamp(0.75, 1.1);

        // اجعل السمك دائمًا ثابت (20) أو نسبة من العرض
        final ringDiameter = cardWidth * (0.80 * internalScale);
        final ringStroke =
            20.0; // ثابت مهما تغير الحجم (يمكنك تغييره لنسبة: max(8.0, ringDiameter * 0.10);)

        return Container(
          decoration: BoxDecoration(
            color: AppColors.ContainerColor,
            borderRadius: BorderRadius.circular(22 * widget.scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                      color: Colors.white,
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
                        color: Colors.white.withOpacity(0.7),
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
  final double caloriesRemaining;
  final double proteinPercent;
  final double carbsPercent;
  final double fatsPercent;
  final double scale;

  const UnifiedMacroChart({
    super.key,
    required this.caloriesRemaining,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatsPercent,
    this.scale = 1.0,
  });

  @override
  State<UnifiedMacroChart> createState() => _UnifiedMacroChartState();
}

class _UnifiedMacroChartState extends State<UnifiedMacroChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
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
    if (oldWidget.proteinPercent != widget.proteinPercent ||
        oldWidget.carbsPercent != widget.carbsPercent ||
        oldWidget.fatsPercent != widget.fatsPercent ||
        oldWidget.caloriesRemaining != widget.caloriesRemaining) {
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
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calories",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(15 * scale),
          Row(
            children: [
              // Left Side: Segmented Ring
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(
                    10 * scale,
                  ), // Padding to make the ring smaller
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
                                protein:
                                    widget.proteinPercent * _animation.value,
                                carbs: widget.carbsPercent * _animation.value,
                                fats: widget.fatsPercent * _animation.value,
                                strokeWidth:
                                    20 * scale, // Slightly thinner stroke
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
                                final currentCalories =
                                    (widget.caloriesRemaining *
                                            _animation.value)
                                        .toInt();
                                return Text(
                                  currentCalories.toString(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize:
                                        24 *
                                        scale, // Slightly smaller font for smaller ring
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            Text(
                              "Remaining",
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 12 * scale,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(60 * scale),
              // Right Side: Labels
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMacroLabel(
                      "Fats",
                      widget.fatsPercent,
                      Colors.blueAccent,
                      scale,
                    ),
                    Gap(16 * scale),
                    _buildMacroLabel(
                      "Protein",
                      widget.proteinPercent,
                      Colors.redAccent,
                      scale,
                    ),
                    Gap(16 * scale),
                    _buildMacroLabel(
                      "Carbs",
                      widget.carbsPercent,
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
    );
  }

  Widget _buildMacroLabel(
    String label,
    double percent,
    Color color,
    double scale,
  ) {
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
                color: color.withOpacity(0.4),
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
                color: Colors.white,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${(percent * 100).toInt()}%",
              style: GoogleFonts.inter(
                color: color,
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SegmentedRingPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fats;
  final double strokeWidth;

  SegmentedRingPainter({
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background ring
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -pi / 2;

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
      ..color = color.withOpacity(0.2)
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
  final double progress;
  final Color color;
  final double strokeWidth;

  AppleBottomLabelRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    const totalAngle = 4 * pi / 3;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade700
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
      colors: [color.withOpacity(0.7), color, color.withOpacity(0.9)],
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
      ..color = color.withOpacity(0.30)
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
