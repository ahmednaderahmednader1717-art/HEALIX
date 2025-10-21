import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class AppleRingCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final double width; // legacy (ignored for layout, kept for backward compat)
  final double height; // legacy (ignored for layout, kept for backward compat)
  final double scale;

  const AppleRingCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.width = 180,
    this.height = 220,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        // اضبط scale داخلي خفيف حسب العرض المتاح للحفاظ على التوازن
        final internalScale = (cardWidth / 180).clamp(0.75, 1.1);

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(22 * scale),
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
              Gap(15 * scale),
              CustomPaint(
                size: Size(
                  cardWidth * (0.60 * internalScale),
                  cardHeight * (0.24 * internalScale),
                ),
                painter: AppleBottomLabelRingPainter(
                  progress: value,
                  color: color,
                ),
              ),
              SizedBox(height: cardHeight * 0.012),
              Column(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontSize: cardHeight * 0.090 * internalScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.005),
                  Text(
                    "${(value * 100).toInt()}%",
                    style: GoogleFonts.inriaSans(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: cardHeight * 0.085 * internalScale,
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

class AppleBottomLabelRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  AppleBottomLabelRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 22.0; // سمك أكبر كما طلبت
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    const totalAngle = 4 * pi / 3; // 240° تقريباً

    // الخلفية الرمادية
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

    // Gradient للحلقة الملونة
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

    // Glow أقوى حول الحلقة
    final glowPaint = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final sweepFilled = totalAngle * progress;

    // ارسم التوهج
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi + (pi - totalAngle) / 2,
      sweepFilled,
      false,
      glowPaint,
    );

    // ارسم الحلقة الملونة
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
