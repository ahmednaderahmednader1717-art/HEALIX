import 'dart:math';
import 'package:flutter/material.dart';

class HealixLogo extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double strokeWidth;

  const HealixLogo({
    super.key,
    required this.size,
    required this.color,
    this.duration = const Duration(seconds: 3),
    this.strokeWidth = 6,
  });

  @override
  State<HealixLogo> createState() => _HealixLogoState();
}

class _HealixLogoState extends State<HealixLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _XIntegratedPainter(
              t: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _XIntegratedPainter extends CustomPainter {
  final double t; // 0 -> 1
  final Color color;
  final double strokeWidth;

  _XIntegratedPainter({
    required this.t,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final maxLength = size.width * 0.35;

    // الحركة اللولبية (كما في التنفيذ الحالي)
    double spiralProgress = (t < 0.7) ? t / 0.7 : 1.0;
    double angle = 2 * pi * 2 * spiralProgress; // لفات
    double radius = (1 - spiralProgress) * 15;

    final spreadFactor = 1.5; // التباعد

    Offset start1 =
        center +
        Offset(
          -maxLength * spiralProgress * spreadFactor,
          -radius * cos(angle),
        );
    Offset end1 =
        center +
        Offset(maxLength * spiralProgress * spreadFactor, radius * sin(angle));

    Offset start2 =
        center +
        Offset(-maxLength * spiralProgress * spreadFactor, radius * cos(angle));
    Offset end2 =
        center +
        Offset(maxLength * spiralProgress * spreadFactor, -radius * sin(angle));

    if (t >= 0.7) {
      double p = (t - 0.7) / 0.3;

      start1 = Offset.lerp(start1, center - Offset(maxLength, -maxLength), p)!;
      end1 = Offset.lerp(end1, center + Offset(maxLength, -maxLength), p)!;

      start2 = Offset.lerp(start2, center - Offset(maxLength, maxLength), p)!;
      end2 = Offset.lerp(end2, center + Offset(maxLength, maxLength), p)!;
    }

    // رسم الخطين
    canvas.drawLine(start1, end1, paint);
    canvas.drawLine(start2, end2, paint);

    // توهج عند التقاطع
    if (t > 0.7) {
      final glowOpacity = ((t - 0.7) / 0.3).clamp(0.0, 1.0);
      final glow = Paint()
        ..color = color.withOpacity(glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 5 + (t - 0.7) * 10, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _XIntegratedPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
