import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';

class EditNutrationGoals extends StatefulWidget {
  final UserInfo user;
  const EditNutrationGoals({super.key, required this.user});

  @override
  State<EditNutrationGoals> createState() => _EditNutrationGoalsState();
}

class _EditNutrationGoalsState extends State<EditNutrationGoals>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;

  final Dio dio = Dio(BaseOptions(baseUrl: 'http://healix26.somee.com/api'));

  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      final response = await dio.get(
        "/nutrition/goals",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _calorieController.text = (data['dailyCalorieGoal'] ?? "0")
              .toString();
          _proteinController.text = (data['dailyProteinGoal'] ?? "0")
              .toString();
          _carbController.text = (data['dailyCarbsGoal'] ?? "0").toString();
          _fatController.text = (data['dailyFatsGoal'] ?? "0").toString();
        });
      }
    } catch (e) {
      print("Error fetching goals: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGoals() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      final payload = {
        "dailyCalorieGoal": double.tryParse(_calorieController.text) ?? 0,
        "dailyProteinGoal": double.tryParse(_proteinController.text) ?? 0,
        "dailyCarbsGoal": double.tryParse(_carbController.text) ?? 0,
        "dailyFatsGoal": double.tryParse(_fatController.text) ?? 0,
      };

      final response = await dio.put(
        "/nutrition/goals",
        data: payload,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nutrition goals updated successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saving goals: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update nutrition goals")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final w = screenWidth / 430;

    return Scaffold(
      backgroundColor: const Color(0xFF16313B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit nutrition goals",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22 * w,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20 * w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24 * w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20 * w),
                  _buildGoalCard(
                    label: "Calorie goal",
                    unit: "kcal",
                    controller: _calorieController,
                    icon: Ionicons.flame,
                    color: Colors.orangeAccent,
                    scale: w,
                    progress: 0.8,
                  ),
                  SizedBox(height: 16 * w),
                  _buildGoalCard(
                    label: "Protein goal",
                    unit: "g",
                    controller: _proteinController,
                    icon: Ionicons.restaurant,
                    color: const Color(0xFFFF6D6D),
                    scale: w,
                    progress: 0.6,
                  ),
                  SizedBox(height: 16 * w),
                  _buildGoalCard(
                    label: "Carb goal",
                    unit: "g",
                    controller: _carbController,
                    icon: Ionicons.leaf,
                    color: const Color(0xFFFFB36D),
                    scale: w,
                    progress: 0.7,
                  ),
                  SizedBox(height: 16 * w),
                  _buildGoalCard(
                    label: "Fat goal",
                    unit: "g",
                    controller: _fatController,
                    icon: Ionicons.nutrition,
                    color: const Color(0xFF6DA4FF),
                    scale: w,
                    progress: 0.5,
                  ),
                  SizedBox(height: 40 * w),
                  _buildSaveButton(w),
                  SizedBox(height: 30 * w),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CupertinoActivityIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String label,
    required String unit,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required double scale,
    required double progress,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 65 * scale,
            height: 65 * scale,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RingPainter(
                    color: color,
                    progress: progress * _animation.value,
                    scale: scale,
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 22 * scale),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 20 * scale),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 14 * scale,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 26 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      unit,
                      style: GoogleFonts.outfit(
                        color: Colors.white30,
                        fontSize: 15 * scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(double w) {
    return Container(
      width: double.infinity,
      height: 55 * w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * w),
        color: AppColors.primarayColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveGoals,
          borderRadius: BorderRadius.circular(16 * w),
          child: Center(
            child: Text(
              "Save Changes",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18 * w),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double scale;

  _RingPainter({
    required this.color,
    required this.progress,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0 * scale;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    canvas.drawCircle(center, radius, paint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start from top
      6.28 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
