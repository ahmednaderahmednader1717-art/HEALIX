import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_splash/models/food_model.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/services/meal_scan_service.dart';
import 'package:test_splash/services/nutrition_service.dart';

class ScanMealTab extends StatefulWidget {
  const ScanMealTab({super.key});

  @override
  State<ScanMealTab> createState() => _ScanMealTabState();
}

class _ScanMealTabState extends State<ScanMealTab>
    with SingleTickerProviderStateMixin {
  File? _capturedImage;
  bool _isAnalyzing = false;
  Food? _result;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  // ── Amount / unit state ──────────────────────────────────────────────────
  late TextEditingController _amountController;
  String _selectedUnit = 'g';
  double _amount = 100.0;
  bool _isLogging = false;
  final List<String> _units = ['g', 'ml', 'piece'];

  // ── Shimmer animation ────────────────────────────────────────────────────
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ── Image capture ────────────────────────────────────────────────────────

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return;
    setState(() {
      _capturedImage = File(photo.path);
      _result = null;
      _error = null;
      _isAnalyzing = false;
    });
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo == null) return;
    setState(() {
      _capturedImage = File(photo.path);
      _result = null;
      _error = null;
      _isAnalyzing = false;
    });
  }

  // ── AI analysis ──────────────────────────────────────────────────────────

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      debugPrint('=== Starting Gemini analysis ===');
      final food = await MealScanService.analyseImage(_capturedImage!);
      debugPrint('=== Analysis success: ${food.name} ===');
      if (!mounted) return;
      setState(() {
        _result = food;
        _isAnalyzing = false;
        
        final unitStr = (food.unitName ?? '').toLowerCase();
        if (unitStr.contains('piece') || unitStr.contains('slice') || unitStr.contains('bowl') || unitStr.contains('cup')) {
          _selectedUnit = 'piece';
          _amount = 1.0;
          _amountController.text = '1';
        } else if (unitStr == 'ml') {
          _selectedUnit = 'ml';
          _amount = 100.0;
          _amountController.text = '100';
        } else {
          _selectedUnit = 'g';
          _amount = 100.0;
          _amountController.text = '100';
        }
      });
    } catch (e, stack) {
      debugPrint('=== Gemini analysis FAILED ===');
      debugPrint('Error: $e');
      debugPrint('Stack: $stack');
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _error = e.toString();
      });
    }
  }

  // ── Nutrition helpers (same logic as MealTile detail sheet) ──────────────

  double get _multiplier {
    if (_selectedUnit == 'piece') {
      final weightToUse = (_result?.weightPerUnit != null && _result!.weightPerUnit! > 0)
          ? _result!.weightPerUnit!
          : 100.0;
      return (_amount * weightToUse) / 100.0;
    }
    return _amount / 100.0;
  }

  int get _adjustedCalories =>
      ((_adjustedProtein * 4) + (_adjustedCarbs * 4) + (_adjustedFats * 9))
          .round();
  double get _adjustedProtein => (_result?.protein ?? 0) * _multiplier;
  double get _adjustedCarbs => (_result?.carbs ?? 0) * _multiplier;
  double get _adjustedFats => (_result?.fats ?? 0) * _multiplier;

  // ── Log the scanned meal ───────────────────────────────────────────────

  Future<void> _logMeal() async {
    if (_result == null) return;

    setState(() => _isLogging = true);
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final docDir = await getApplicationDocumentsDirectory();
      final String fileName = "scan_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final String localImagePath = '${docDir.path}/$fileName';
      final savedImage = await _capturedImage!.copy(localImagePath);

      // Negative IDs distinguish them from real backend IDs
      final randomId = -1 * (DateTime.now().millisecondsSinceEpoch % 1000000);

      final localLog = NutritionLog(
        id: randomId,
        foodId: randomId,
        foodName: _result!.name ?? 'Unknown AI Meal',
        imageUrl: savedImage.path,
        quantity: _amount,
        unitName: _selectedUnit,
        measurementType: 'Unit',
        protein: _adjustedProtein,
        carbs: _adjustedCarbs,
        fats: _adjustedFats,
        calories: _adjustedCalories.toDouble(),
        date: dateStr,
      );

      await NutritionService().saveLocalLog(localLog, dateStr);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Saved ${_result!.name} to your diary locally'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void _reset() => setState(() {
        _capturedImage = null;
        _result = null;
        _error = null;
        _isAnalyzing = false;
        _isLogging = false;
      });

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);

    // Decide which view to show
    if (_capturedImage == null) {
      return _buildScanPrompt(context, w, h, scale);
    }
    if (_result != null) {
      return _buildResults(context, w, h, scale);
    }
    return _buildPreview(context, w, h, scale);
  }

  // ── 1. No image yet ─────────────────────────────────────────────────────

  Widget _buildScanPrompt(BuildContext context, double w, double h, double scale) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20 * w,
          right: 20 * w,
          top: 50 * h,
          bottom: 120 * h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Meal',
              style: GoogleFonts.inter(
                color: colorScheme.onSurface,
                fontSize: 32 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * h),
            Text(
              'Take a photo to identify your meal and its nutrition.',
              style: GoogleFonts.inter(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14 * scale,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32 * h),

            // Camera tap zone
            Expanded(
              child: GestureDetector(
                onTap: _openCamera,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24 * scale),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80 * scale,
                        height: 80 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onSurface.withValues(alpha: 0.06),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: colorScheme.onSurface,
                          size: 36 * scale,
                        ),
                      ),
                      SizedBox(height: 20 * h),
                      Text(
                        'Tap to open camera',
                        style: GoogleFonts.inter(
                          color: colorScheme.onSurface,
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * h),
                      Text(
                        'Point at your meal and snap a photo',
                        style: GoogleFonts.inter(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16 * h),

            // Gallery button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: Icon(
                  Icons.photo_library_outlined,
                  color: colorScheme.onSurface,
                ),
                label: Text(
                  'Pick from Gallery',
                  style: GoogleFonts.inter(
                    color: colorScheme.onSurface,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16 * h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Image preview (before / during analysis) ─────────────────────────

  Widget _buildPreview(BuildContext context, double w, double h, double scale) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20 * w,
          right: 20 * w,
          top: 80 * h,
          bottom: 120 * h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Meal Photo',
                  style: GoogleFonts.inter(
                    color: colorScheme.onSurface,
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _chipButton(
                  context,
                  icon: Icons.refresh_rounded,
                  label: 'Retake',
                  onTap: _reset,
                  scale: scale,
                  w: w,
                  h: h,
                ),
              ],
            ),
            SizedBox(height: 16 * h),

            // Photo
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20 * scale),
                    child: Image.file(
                      _capturedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Shimmer overlay while analysing
                  if (_isAnalyzing)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20 * scale),
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (_, __) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(-1.0 +
                                      2.0 * _shimmerController.value,
                                      0),
                                  end: Alignment(
                                      1.0 + 2.0 * _shimmerController.value,
                                      0),
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    colorScheme.onSurface.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 32 * scale,
                                      height: 32 * scale,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 16 * h),
                                    Text(
                                      'Analysing meal…',
                                      style: GoogleFonts.inter(
                                        color: colorScheme.onSurface,
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20 * h),

            // Error message
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: colorScheme.error, size: 20 * scale),
                        SizedBox(width: 8 * w),
                        Expanded(
                          child: Text(
                            'Analysis failed',
                            style: GoogleFonts.inter(
                              color: colorScheme.error,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      _error ?? 'Unknown error',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: colorScheme.error.withValues(alpha: 0.8),
                        fontSize: 11 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12 * h),
            ],

            // Analyse button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16 * h),
                ),
                child: _isAnalyzing
                    ? SizedBox(
                        width: 20 * scale,
                        height: 20 * scale,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.surface.withValues(alpha: 0.6),
                        ),
                      )
                    : Text(
                        _error != null ? 'Retry  ↻' : 'Analyse Meal  →',
                        style: GoogleFonts.inter(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Results view ──────────────────────────────────────────────────────

  Widget _buildResults(BuildContext context, double w, double h, double scale) {
    final food = _result!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20 * w,
                right: 20 * w,
                top: 80 * h,
                bottom: 120 * h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Scan Result',
                        style: GoogleFonts.inter(
                          color: colorScheme.onSurface,
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _chipButton(
                        context,
                        icon: Icons.camera_alt_rounded,
                        label: 'Scan Another',
                        onTap: _reset,
                        scale: scale,
                        w: w,
                        h: h,
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * h),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20 * scale),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.file(
                        _capturedImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20 * h),

                  // Meal name
                  Text(
                    food.name ?? 'Unknown Meal',
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurface,
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (food.description != null &&
                      food.description!.isNotEmpty) ...[
                    SizedBox(height: 6 * h),
                    Text(
                      food.description!,
                      style: GoogleFonts.inter(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14 * scale,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: 20 * h),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * w,
                      vertical: 6 * h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            color: colorScheme.primary,
                            size: 16 * scale),
                        SizedBox(width: 6 * w),
                        Text(
                          'Estimated by AI · per ${_amount.toStringAsFixed(0)}$_selectedUnit',
                          style: GoogleFonts.inter(
                            color: colorScheme.primary,
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * h),

                  // Macro cards
                  Row(
                    children: [
                      _buildNutrientCard(
                        context,
                        'Calories',
                        '$_adjustedCalories',
                        'kcal',
                        const Color(0xFFFFB36D),
                        Icons.local_fire_department_rounded,
                        scale,
                      ),
                      _buildNutrientCard(
                        context,
                        'Protein',
                        _adjustedProtein.toStringAsFixed(1),
                        'g',
                        const Color(0xFFFF6D6D),
                        Icons.fitness_center_rounded,
                        scale,
                      ),
                      _buildNutrientCard(
                        context,
                        'Carbs',
                        _adjustedCarbs.toStringAsFixed(1),
                        'g',
                        const Color(0xFFFFB36D),
                        Icons.pie_chart_rounded,
                        scale,
                      ),
                      _buildNutrientCard(
                        context,
                        'Fats',
                        _adjustedFats.toStringAsFixed(1),
                        'g',
                        const Color(0xFF6DA4FF),
                        Icons.water_drop_rounded,
                        scale,
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * h),

                  // Amount + unit selector
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 8 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 24 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _amount = double.tryParse(val) ?? 0.0;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40 * scale,
                          width: 1,
                          color: colorScheme.outlineVariant,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16 * scale),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            dropdownColor: theme.scaffoldBackgroundColor,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: colorScheme.onSurfaceVariant),
                            onChanged: (u) {
                              if (u != null) {
                                setState(() => _selectedUnit = u);
                              }
                            },
                            items: _units.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(
                                  u,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18 * scale,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * h),

                  // Log button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLogging ? null : _logMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 4,
                        shadowColor:
                            colorScheme.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        minimumSize: Size(double.infinity, 56 * scale),
                      ),
                      child: _isLogging
                          ? SizedBox(
                              width: 22 * scale,
                              height: 22 * scale,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Add to Diary',
                              style: GoogleFonts.inter(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared UI helpers ────────────────────────────────────────────────────

  Widget _chipButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double scale,
    required double w,
    required double h,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * w, vertical: 6 * h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20 * scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 16 * scale),
            SizedBox(width: 4 * w),
            Text(
              label,
              style: GoogleFonts.inter(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
    double scale,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4 * scale),
        padding: EdgeInsets.symmetric(vertical: 12 * scale),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20 * scale),
            SizedBox(height: 8 * scale),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
            ),
            SizedBox(height: 4 * scale),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontSize: 10 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
