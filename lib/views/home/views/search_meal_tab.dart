import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/views/home/widgets/custom_search_bar.dart';
import 'package:test_splash/views/home/widgets/meal_tile.dart';
import 'package:test_splash/models/food_model.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/services/food_service.dart';
import 'package:test_splash/services/auth_service.dart';
import 'package:test_splash/services/nutrition_service.dart';

class SearchMealTab extends StatefulWidget {
  const SearchMealTab({super.key});

  @override
  State<SearchMealTab> createState() => _SearchMealTabState();
}

class _SearchMealTabState extends State<SearchMealTab> {
  final FoodService _foodService = FoodService();

  List<Food> _filteredFoods = [];
  List<Food> _recentFoods = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDiet = 'Standard';
  final Set<String> _selectedCategories = {};

  final List<String> _dietTypes = [
    'Standard',
    'Vegan',
    'Vegetarian',
    'Pescatarian',
  ];

  final List<String> _categories = [
    'Protein',
    'Carbs',
    'Fats',
    'Dairy',
    'Fruits',
    'Vegetables',
    'Drinks',
    'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoading = true);
    try {
      List<Food> foods;

      final hasDietFilter = _selectedDiet != 'Standard';
      final hasCategoryFilter = _selectedCategories.isNotEmpty;

      if (hasDietFilter || hasCategoryFilter) {
        // Send both dietType and categories array to the server in one request.
        foods = await _foodService.filterFoods(
          dietType: hasDietFilter ? _selectedDiet : null,
          categories: hasCategoryFilter ? _selectedCategories.toList() : null,
        );

        // Narrow by search query if also present.
        if (_searchQuery.isNotEmpty) {
          foods = foods.where((food) {
            final name = food.name?.toLowerCase() ?? '';
            final desc = food.description?.toLowerCase() ?? '';
            return name.contains(_searchQuery) || desc.contains(_searchQuery);
          }).toList();
        }
      } else if (_searchQuery.isNotEmpty) {
        foods = await _foodService.searchFoods(_searchQuery);
      } else {
        foods = await _foodService.getFoods();
        _calculateRecentFoods(foods);
      }

      setState(() {
        _filteredFoods = foods;
      });
    } catch (e) {
      debugPrint('Error fetching foods: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateRecentFoods(List<Food> allFoods) async {
    final today = DateTime.now();
    final futures = <Future<DailySummary?>>[];
    for (int i = 0; i < 5; i++) {
      final d = today.subtract(Duration(days: i));
      futures.add(
        NutritionService().getDailySummary(
          date:
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        ),
      );
    }
    final summaries = await Future.wait(futures);

    final ids = <int>{};
    for (final summary in summaries) {
      if (summary != null) {
        for (final log in summary.logs) {
          if (log.foodId > 0) ids.add(log.foodId);
        }
      }
    }

    final recent = <Food>[];
    for (final id in ids) {
      try {
        recent.add(allFoods.firstWhere((f) => f.id == id));
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _recentFoods = recent);
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query.trim().toLowerCase();
    _fetchFoods();
  }

  void _onFilterChanged(String diet) {
    setState(() {
      _selectedDiet = diet;
    });
    _fetchFoods();
  }

  void _removeCategory(String category) {
    setState(() => _selectedCategories.remove(category));
    _fetchFoods();
  }

  void _showFilterBottomSheet(double scale, double h, double w) {
    // Work on a local copy so Apply is needed to confirm.
    final localSelected = Set<String>.from(_selectedCategories);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * w,
                vertical: 24 * h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Category',
                        style: GoogleFonts.inter(
                          color: colorScheme.onSurface,
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Gap(16 * h),
                  Wrap(
                    spacing: 8 * w,
                    runSpacing: 8 * h,
                    children: _categories.map((category) {
                      final isSelected = localSelected.contains(category);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              localSelected.remove(category);
                            } else {
                              localSelected.add(category);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * w,
                            vertical: 10 * h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.inter(
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                              fontSize: 14 * scale,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Gap(20 * h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() => localSelected.clear());
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14 * h),
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.inter(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Gap(12 * w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategories
                                ..clear()
                                ..addAll(localSelected);
                            });
                            _fetchFoods();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14 * h),
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.inter(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(8 * h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    await AuthService().refreshToken();
    await _fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(80 * h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * w),
          child: Text(
            'Search Meals',
            style: GoogleFonts.inter(
              color: colorScheme.onSurface,
              fontSize: 32 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Gap(16 * h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * w),
          child: CustomSearchBar(
            scale: scale,
            onChanged: _onSearchChanged,
            onFilterPressed: () => _showFilterBottomSheet(scale, h, w),
          ),
        ),
        Gap(16 * h),
        SizedBox(
          height: 48 * h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16 * w),
            itemCount: _dietTypes.length,
            itemBuilder: (context, index) {
              final diet = _dietTypes[index];
              final isSelected = _selectedDiet == diet;
              return Padding(
                padding: EdgeInsets.only(right: 8 * w),
                child: ChoiceChip(
                  label: Text(
                    diet,
                    style: GoogleFonts.inter(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      fontSize: 14 * scale,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _onFilterChanged(diet),
                  selectedColor: colorScheme.primary,
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        if (_selectedCategories.isNotEmpty) ...[
          Gap(12 * h),
          Padding(
            padding: EdgeInsets.only(left: 16 * w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Text(
                    'Category: ',
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 12 * scale,
                    ),
                  ),
                  ..._selectedCategories.map((cat) {
                    return Padding(
                      padding: EdgeInsets.only(right: 6 * w),
                      child: GestureDetector(
                        onTap: () => _removeCategory(cat),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * w,
                            vertical: 4 * h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8 * scale),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat,
                                style: GoogleFonts.inter(
                                  color: colorScheme.primary,
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Gap(4 * w),
                              Icon(
                                Icons.close,
                                size: 14 * scale,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
        Gap(12 * h),

        if (_recentFoods.isNotEmpty &&
            _searchQuery.isEmpty &&
            _selectedCategories.isEmpty &&
            _selectedDiet == 'Standard') ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * w),
            child: Text(
              'Recently Logged',
              style: GoogleFonts.inter(
                color: colorScheme.onSurface,
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Gap(12 * h),
          SizedBox(
            height: 96 * scale,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16 * w),
              itemCount: _recentFoods.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 12 * w),
                  child: SizedBox(
                    width: 280 * w,
                    child: MealTile(food: _recentFoods[index], scale: scale),
                  ),
                );
              },
            ),
          ),
          Gap(16 * h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * w),
            child: Text(
              'All Meals',
              style: GoogleFonts.inter(
                color: colorScheme.onSurface,
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Gap(12 * h),
        ],

        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: _onRefresh),
              if (_isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: colorScheme.onSurface,
                      radius: 14,
                    ),
                  ),
                )
              else if (_filteredFoods.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, scale, h),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 16 * w,
                    right: 16 * w,
                    bottom: 120 * h,
                    top: 10 * h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12 * h),
                        child: MealTile(
                          food: _filteredFoods[index],
                          scale: scale,
                        ),
                      );
                    }, childCount: _filteredFoods.length),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, double scale, double h) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80 * scale,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          SizedBox(height: 24 * h),
          Text(
            'No Meals Found',
            style: GoogleFonts.inriaSans(
              color: colorScheme.onSurface,
              fontSize: 24 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12 * h),
          Text(
            "We couldn't find anything matching your criteria.\nTry adjusting your search or filters.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inriaSans(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16 * scale,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40 * h),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedDiet = 'Standard';
                _selectedCategories.clear();
              });
              _fetchFoods();
            },
            icon: Icon(
              Icons.refresh,
              color: colorScheme.primary,
              size: 20 * scale,
            ),
            label: Text(
              'Reset Filters',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12 * scale,
                horizontal: 24 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
