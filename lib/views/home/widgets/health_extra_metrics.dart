import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/widgets/home/charts_widget.dart';
import 'package:test_splash/services/health_service.dart';

class HealthExtraMetrics extends StatefulWidget {
  final double scale;

  const HealthExtraMetrics({super.key, this.scale = 1.0});

  @override
  State<HealthExtraMetrics> createState() => _HealthExtraMetricsState();
}

class _HealthExtraMetricsState extends State<HealthExtraMetrics> {
  int waterMl = 0;
  int _steps = 0;
  double _caloriesBurned = 0;
  final int _stepsGoal = 10000;
  bool _loadingSteps = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final results = await Future.wait([
      HealthService().getTodaySteps(),
      HealthService().getTodayCaloriesBurned(),
    ]);
    if (mounted) {
      setState(() {
        _steps = (results[0] as int?) ?? 0;
        _caloriesBurned = (results[1] as double?) ?? 0;
        _loadingSteps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Steps & Calories Burned
          Row(
            children: [
              Expanded(flex: 5, child: _buildStepsCard(context, scale)),
              Gap(12 * scale),
              Expanded(flex: 5, child: _buildCaloriesBurnedCard(context, scale)),
            ],
          ),
          Gap(12 * scale),
          // Bottom Row: Water Log
          _buildWaterCard(context, scale),
        ],
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, double scale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 160 * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Steps",
            style: GoogleFonts.inter(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(4 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _loadingSteps ? '--' : '$_steps',
                style: GoogleFonts.inter(
                  color: colorScheme.onSurface,
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' /$_stepsGoal',
                style: GoogleFonts.inter(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * scale),
              child: FittedBox(
                child: SizedBox(
                  width: 100 * scale,
                  height: 100 * scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background track ring
                      CustomPaint(
                        size: Size.infinite,
                        painter: SegmentedRingPainter(
                          context: context,
                          protein: 0,
                          carbs: 0,
                          fats: 0,
                          strokeWidth: 8 * scale,
                          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.15),
                        ),
                      ),
                      // Progress arc
                      CustomPaint(
                        size: Size.infinite,
                        painter: SegmentedRingPainter(
                          context: context,
                          protein: 0,
                          carbs: 0,
                          fats: 0,
                          genericProgress: (_steps / _stepsGoal).clamp(0.0, 1.0),
                          genericColor: Colors.white,
                          strokeWidth: 8 * scale,
                        ),
                      ),
                      Icon(
                        Icons.directions_walk_rounded,
                        color: colorScheme.onSurface,
                        size: 32 * scale,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesBurnedCard(BuildContext context, double scale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 160 * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calories burned",
            style: GoogleFonts.inter(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(4 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _loadingSteps ? '--' : _caloriesBurned.toStringAsFixed(0),
                style: GoogleFonts.inter(
                  color: colorScheme.onSurface,
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(4 * scale),
              Text(
                "cal",
                style: GoogleFonts.inter(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap(20 * scale),
          Row(
            children: [
              Icon(
                Icons.directions_walk_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 24 * scale,
              ),
              Gap(8 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Steps",
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurface,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${_caloriesBurned.toStringAsFixed(0)} cal",
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard(BuildContext context, double scale) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Basic Text Emoji Icon Replacement
          Text(
            "🥛",
            style: TextStyle(fontSize: 32 * scale),
          ),
          Gap(16 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Water",
                style: GoogleFonts.inter(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "$waterMl ml",
                style: GoogleFonts.inter(
                  color: colorScheme.onSurface,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                waterMl += 250;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * scale),
                side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
              ),
            ),
            child: Text(
              "Log Water",
              style: GoogleFonts.inter(
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
