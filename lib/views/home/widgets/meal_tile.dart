import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/food_model.dart';
import 'package:test_splash/services/nutrition_service.dart';

class MealTile extends StatelessWidget {
  final Food food;
  final double scale;

  const MealTile({super.key, required this.food, required this.scale});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.ContainerColor,
          builder: (context) => _MealDetailsSheet(food: food, scale: scale),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ContainerColor,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * scale),
                bottomLeft: Radius.circular(16 * scale),
              ),
              child: (food.imageUrl != null && food.imageUrl!.isNotEmpty)
                  ? Image.network(
                      food.imageUrl!,
                      width: 110 * scale,
                      height: 90 * scale,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(scale, width: 110, height: 90),
                    )
                  : _buildPlaceholder(scale, width: 110, height: 90),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      food.name ?? 'Unknown Meal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orangeAccent,
                          size: 16 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          "${food.calories} kcal",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12 * scale,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10 * scale),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.ContainerColor,
                    builder: (context) =>
                        _MealDetailsSheet(food: food, scale: scale),
                  );
                },
                icon: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarayColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: AppColors.primarayColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double scale, {double? width, double? height}) {
    return Container(
      width: width != null ? width * scale : double.infinity,
      height: height != null ? height * scale : double.infinity,
      color: Colors.white12,
      child: Image.asset('assets/covers/IMG_1049.JPG', fit: BoxFit.cover),
    );
  }
}

class _MealDetailsSheet extends StatefulWidget {
  final Food food;
  final double scale;

  const _MealDetailsSheet({required this.food, required this.scale});

  @override
  State<_MealDetailsSheet> createState() => _MealDetailsSheetState();
}

class _MealDetailsSheetState extends State<_MealDetailsSheet> {
  final NutritionService _nutritionService = NutritionService();
  late TextEditingController _amountController;
  late String _selectedUnit;
  double _amount = 100.0;
  bool _isLogging = false;

  final List<String> _units = ['g', 'ml', 'piece'];

  @override
  void initState() {
    super.initState();
    _selectedUnit = _baseUnit;
    _amount = _baseValue;
    _amountController = TextEditingController(text: _amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _baseValue {
    switch (widget.food.unitName?.toLowerCase()) {
      case 'piece':
      case 'pieces':
        return 1.0;
      case 'ml':
        return 100.0;
      case 'g':
      default:
        return 100.0;
    }
  }

  String get _baseUnit {
    switch (widget.food.unitName?.toLowerCase()) {
      case 'piece':
      case 'pieces':
        return 'piece';
      case 'ml':
        return 'ml';
      case 'g':
      default:
        return 'g';
    }
  }

  double get _multiplier {
    if (_baseUnit == 'piece') {
      if (_selectedUnit == 'piece') {
        return _amount / 1.0;
      } else {
        double wpu = widget.food.weightPerUnit ?? 100.0;
        return _amount / wpu;
      }
    } else {
      if (_selectedUnit == 'piece') {
        double wpu = widget.food.weightPerUnit ?? 100.0;
        return (_amount * wpu) / _baseValue;
      } else {
        return _amount / _baseValue;
      }
    }
  }

  int get _adjustedCalories =>
      ((_adjustedProtein * 4) + (_adjustedCarbs * 4) + (_adjustedFats * 9))
          .round();
  double get _adjustedProtein => widget.food.protein * _multiplier;
  double get _adjustedCarbs => widget.food.carbs * _multiplier;
  double get _adjustedFats => widget.food.fats * _multiplier;

  void _onAmountChanged(String val) {
    setState(() {
      _amount = double.tryParse(val) ?? 0.0;
    });
  }

  void _onUnitChanged(String? newUnit) {
    if (newUnit != null) {
      setState(() {
        _selectedUnit = newUnit;
      });
    }
  }

  Future<void> _logFood() async {
    if (widget.food.id == null || _amount <= 0) return;
    setState(() => _isLogging = true);
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final log = await _nutritionService.logFood(
        foodId: widget.food.id!,
        quantity: _amount,
        date: dateStr,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            log != null
                ? '✓ Added ${widget.food.name} to your diary'
                : 'Failed to log meal. Please try again.',
          ),
          backgroundColor: log != null ? AppColors.primarayColor : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.ContainerColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20 * scale),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20 * scale,
                left: 20 * scale,
                right: 20 * scale,
                top: 10 * scale,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 5 * scale,
                      width: 40 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16 * scale),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child:
                          (widget.food.imageUrl != null &&
                              widget.food.imageUrl!.isNotEmpty)
                          ? Image.network(
                              widget.food.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(scale),
                            )
                          : _buildPlaceholder(scale),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    widget.food.name ?? 'Unknown Meal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Interactive Amount and Unit Selector
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
                                      decimal: true,
                                    ),
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
                                onChanged: _onAmountChanged,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40 * scale,
                          width: 1 * scale,
                          color: Colors.white12,
                          margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            dropdownColor: AppColors.ContainerColor,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                            ),
                            onChanged: _onUnitChanged,
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
                  SizedBox(height: 24 * scale),

                  Row(
                    children: [
                      _buildNutrientInfo(
                        'Calories',
                        '$_adjustedCalories',
                        'kcal',
                        Colors.orangeAccent,
                        Icons.local_fire_department_rounded,
                        scale,
                      ),
                      _buildNutrientInfo(
                        'Protein',
                        _adjustedProtein.toStringAsFixed(1),
                        'g',
                        Colors.redAccent,
                        Icons.fitness_center_rounded,
                        scale,
                      ),
                      _buildNutrientInfo(
                        'Carbs',
                        _adjustedCarbs.toStringAsFixed(1),
                        'g',
                        Colors.amberAccent,
                        Icons.pie_chart_rounded,
                        scale,
                      ),
                      _buildNutrientInfo(
                        'Fats',
                        _adjustedFats.toStringAsFixed(1),
                        'g',
                        Colors.blueAccent,
                        Icons.water_drop_rounded,
                        scale,
                      ),
                    ],
                  ),
                  SizedBox(height: 30 * scale),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white54,
                              size: 18 * scale,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * scale),
                        Text(
                          widget.food.description?.isNotEmpty == true
                              ? widget.food.description!
                              : 'No description available for this meal.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14 * scale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarayColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primarayColor.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      minimumSize: Size(double.infinity, 56 * scale),
                    ),
                    onPressed: _isLogging ? null : _logFood,
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
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientInfo(
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
              text: TextSpan(
                children: [
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
                ],
              ),
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

  Widget _buildPlaceholder(double scale, {double? width, double? height}) {
    return Container(
      width: width != null ? width * scale : double.infinity,
      height: height != null ? height * scale : double.infinity,
      color: Colors.white12,
      child: Image.asset('assets/covers/IMG_1049.JPG', fit: BoxFit.cover),
    );
  }
}
