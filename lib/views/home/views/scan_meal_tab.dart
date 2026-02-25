import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_splash/core/app_colors.dart';

class ScanMealTab extends StatefulWidget {
  const ScanMealTab({super.key});

  @override
  State<ScanMealTab> createState() => _ScanMealTabState();
}

class _ScanMealTabState extends State<ScanMealTab> {
  File? _capturedImage;
  bool _isAnalyzing = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return;
    setState(() {
      _capturedImage = File(photo.path);
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
      _isAnalyzing = false;
    });
  }

  void _analyzeImage() {
    if (_capturedImage == null) return;
    setState(() => _isAnalyzing = true);
    // TODO: connect to your nutrition-analysis API here
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isAnalyzing = false);
    });
  }

  void _reset() => setState(() {
    _capturedImage = null;
    _isAnalyzing = false;
  });

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

    return _capturedImage == null
        ? _buildScanPrompt(context, toolbarHeight, w, h, scale)
        : _buildPreview(context, toolbarHeight, w, h, scale);
  }

  // ── No image yet ────────────────────────────────────────────────────────────
  Widget _buildScanPrompt(
    BuildContext context,
    double toolbarHeight,
    double w,
    double h,
    double scale,
  ) {
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

            // ── Camera tap zone ─────────────────────────────────────────────
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
                      // Camera icon with glow
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

            // ── Divider ──────────────────────────────────────────────────────

            // ── Gallery button ───────────────────────────────────────────────
          ],
        ),
      ),
    );
  }

  // ── Image preview ────────────────────────────────────────────────────────────
  Widget _buildPreview(
    BuildContext context,
    double toolbarHeight,
    double w,
    double h,
    double scale,
  ) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20 * w,
          right: 20 * w,
          top: toolbarHeight,
          bottom: 120 * h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                // Retake button
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * w,
                      vertical: 6 * h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ContainerColor,
                      borderRadius: BorderRadius.circular(20 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.grey[300],
                          size: 16 * scale,
                        ),
                        SizedBox(width: 4 * w),
                        Text(
                          'Retake',
                          style: GoogleFonts.inter(
                            color: Colors.grey[300],
                            fontSize: 13 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * h),

            // ── Photo ────────────────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * scale),
                child: Image.file(
                  _capturedImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20 * h),

            // ── Analyse button ───────────────────────────────────────────────
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
                        'Analyse Meal  →',
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
}
