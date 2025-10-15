import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();

    // بعد 4.5 ثواني ننتقل للصفحة الرئيسية
    Timer(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _progress,
              child: const Text(
                "HEALI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(width: 5),
            AnimatedBuilder(
              animation: _progress,
              builder: (_, __) {
                return CustomPaint(
                  painter: DNAToXPainterWithGlow(_progress.value),
                  size: const Size(65, 65),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// DNA-style animation transforming into Bold X with glow
class DNAToXPainterWithGlow extends CustomPainter {
  final double t;
  DNAToXPainterWithGlow(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primarayColor, AppColors.primarayColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primarayColor, AppColors.primarayColor],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final half = size.width * 0.35;
    final finalStart1 = center + Offset(-half, -half);
    final finalEnd1 = center + Offset(half * 1.05, half * 1.05);
    final finalStart2 = center + Offset(-half, half);
    final finalEnd2 = center + Offset(half * 0.95, -half * 0.95);

    final path1 = Path();
    final path2 = Path();

    int segments = 30;
    for (int i = 0; i <= segments; i++) {
      double progress = i / segments;

      double twist = (1 - t) * pi * 2;
      double yOffset1 = 0.4 * sin(2 * pi * (progress + t)) * size.height * 0.5;
      double yOffset2 =
          0.4 * sin(2 * pi * (progress + t + 0.5)) * size.height * 0.5;

      Offset pos1 = Offset(
        lerpDouble(-size.width / 2, size.width / 2, progress)!,
        yOffset1,
      );
      Offset pos2 = Offset(
        lerpDouble(-size.width / 2, size.width / 2, progress)!,
        yOffset2,
      );

      double angle1 = twist * (1 - progress);
      double angle2 = -twist * (1 - progress);

      Offset rotated1 = Offset(
        pos1.dx * cos(angle1) - pos1.dy * sin(angle1),
        pos1.dx * sin(angle1) + pos1.dy * cos(angle1),
      );
      Offset rotated2 = Offset(
        pos2.dx * cos(angle2) - pos2.dy * sin(angle2),
        pos2.dx * sin(angle2) + pos2.dy * cos(angle2),
      );

      double progressToX = (t > 0.7) ? (t - 0.7) / 0.3 : 0;

      Offset finalPos1 = Offset.lerp(
        center + rotated1,
        Offset.lerp(finalStart1, finalEnd1, progress)!,
        progressToX,
      )!;

      Offset finalPos2 = Offset.lerp(
        center + rotated2,
        Offset.lerp(finalStart2, finalEnd2, progress)!,
        progressToX,
      )!;

      if (i == 0) {
        path1.moveTo(finalPos1.dx, finalPos1.dy);
        path2.moveTo(finalPos2.dx, finalPos2.dy);
      } else {
        path1.lineTo(finalPos1.dx, finalPos1.dy);
        path2.lineTo(finalPos2.dx, finalPos2.dy);
      }
    }

    // رسم الخطوط
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);

    // رسم التوهج عند تقاطع الخطين
    if (t > 0.8) {
      final glowPaint = Paint()
        ..color = AppColors.primarayColor.withOpacity((t - 0.8) * 5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, 6 + (t - 0.8) * 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DNAToXPainterWithGlow oldDelegate) =>
      oldDelegate.t != t;
}


