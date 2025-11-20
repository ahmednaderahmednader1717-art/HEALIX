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
            18.0; // ثابت مهما تغير الحجم (يمكنك تغييره لنسبة: max(8.0, ringDiameter * 0.10);)

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
      ..color = color.withOpacity(0.55)
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
