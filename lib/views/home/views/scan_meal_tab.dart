import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_splash/core/app_colors.dart';
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
          backgroundColor: AppColors.primarayColor,
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
      return _buildScanPrompt(w, h, scale);
    }
    if (_result != null) {
      return _buildResults(w, h, scale);
    }
    return _buildPreview(w, h, scale);
  }

  // ── 1. No image yet ─────────────────────────────────────────────────────

  Widget _buildScanPrompt(double w, double h, double scale) {
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
                color: Colors.white,
                fontSize: 32 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * h),
            Text(
              'Take a photo to identify your meal and its nutrition.',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
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
                    color: AppColors.ContainerColor,
                    borderRadius: BorderRadius.circular(24 * scale),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
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
                          color: Colors.white.withValues(alpha: 0.06),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 36 * scale,
                        ),
                      ),
                      SizedBox(height: 20 * h),
                      Text(
                        'Tap to open camera',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * h),
                      Text(
                        'Point at your meal and snap a photo',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
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
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                ),
                label: Text(
                  'Pick from Gallery',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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

  Widget _buildPreview(double w, double h, double scale) {
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
                    color: Colors.white,
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _chipButton(
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
                                    Colors.white.withValues(alpha: 0.08),
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
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 16 * h),
                                    Text(
                                      'Analysing meal…',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
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
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 20 * scale),
                        SizedBox(width: 8 * w),
                        Expanded(
                          child: Text(
                            'Analysis failed',
                            style: GoogleFonts.inter(
                              color: Colors.redAccent,
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
                        color: Colors.redAccent.withValues(alpha: 0.8),
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
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16 * h),
                ),
                child: _isAnalyzing
                    ? SizedBox(
                        width: 20 * scale,
                        height: 20 * scale,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
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

  Widget _buildResults(double w, double h, double scale) {
    final food = _result!;

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
                          color: Colors.white,
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _chipButton(
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
                      color: Colors.white,
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
                        color: Colors.grey[400],
                        fontSize: 14 * scale,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: 20 * h),

                  // AI badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * w,
                      vertical: 6 * h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarayColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(
                        color: AppColors.primarayColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            color: AppColors.primarayColor,
                            size: 16 * scale),
                        SizedBox(width: 6 * w),
                        Text(
                          'Estimated by AI · per ${_amount.toStringAsFixed(0)}$_selectedUnit',
                          style: GoogleFonts.inter(
                            color: AppColors.primarayColor,
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
                        'Calories',
                        '$_adjustedCalories',
                        'kcal',
                        Colors.orangeAccent,
                        Icons.local_fire_department_rounded,
                        scale,
                      ),
                      _buildNutrientCard(
                        'Protein',
                        _adjustedProtein.toStringAsFixed(1),
                        'g',
                        Colors.redAccent,
                        Icons.fitness_center_rounded,
                        scale,
                      ),
                      _buildNutrientCard(
                        'Carbs',
                        _adjustedCarbs.toStringAsFixed(1),
                        'g',
                        Colors.amberAccent,
                        Icons.pie_chart_rounded,
                        scale,
                      ),
                      _buildNutrientCard(
                        'Fats',
                        _adjustedFats.toStringAsFixed(1),
                        'g',
                        Colors.blueAccent,
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
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: Colors.white12),
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
                                  color: Colors.white54,
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
                                  color: Colors.white,
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
                          color: Colors.white12,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16 * scale),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            dropdownColor: AppColors.ContainerColor,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white70),
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
                                    color: Colors.white,
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
                        backgroundColor: AppColors.primarayColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor:
                            AppColors.primarayColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        minimumSize: Size(double.infinity, 56 * scale),
                      ),
                      child: _isLogging
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
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

  Widget _chipButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double scale,
    required double w,
    required double h,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * w, vertical: 6 * h),
        decoration: BoxDecoration(
          color: AppColors.ContainerColor,
          borderRadius: BorderRadius.circular(20 * scale),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[300], size: 16 * scale),
            SizedBox(width: 4 * w),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[300],
                fontSize: 13 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
    double scale,
  ) {
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
                    color: Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: Colors.white70,
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
