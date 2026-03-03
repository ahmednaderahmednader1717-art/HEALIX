import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/views/home/widgets/custom_search_bar.dart';
import 'package:test_splash/views/home/widgets/meal_tile.dart';
import 'package:test_splash/models/food_model.dart';
import 'package:test_splash/services/food_service.dart';
import 'package:test_splash/services/auth_service.dart';
import 'package:test_splash/core/app_colors.dart';

class SearchMealTab extends StatefulWidget {
  const SearchMealTab({super.key});

  @override
  State<SearchMealTab> createState() => _SearchMealTabState();
}

class _SearchMealTabState extends State<SearchMealTab> {
  final FoodService _foodService = FoodService();

  List<Food> _filteredFoods = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDiet = 'All';
  String _selectedCategory = 'All';

  final List<String> _dietTypes = [
    'All',
    'Vegan',
    'Vegetarian',
    'Pescatarian',
    'Standard',
  ];

  final List<String> _categories = [
    'All',
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

      // 1. Prioritize Fetch Endpoints
      // Use the specialized diet endpoint for all diets including Standard
      if (_selectedDiet != 'All') {
        foods = await _foodService.getFoodsByDiet(_selectedDiet);
      } else if (_selectedCategory != 'All') {
        foods = await _foodService.getFoodsByCategory(_selectedCategory);
      } else if (_searchQuery.isNotEmpty) {
        foods = await _foodService.searchFoods(_searchQuery);
      } else {
        foods = await _foodService.getFoods();
      }

      // 2. Refine results locally against ALL active criteria
      final refinedList = foods.where((food) {
        // Diet check (Hierarchical)
        bool dietMatch = false;
        final diet = food.dietType?.toLowerCase() ?? '';

        if (_selectedDiet == 'All' || _selectedDiet == 'Standard') {
          dietMatch = true;
        } else if (_selectedDiet == 'Vegan') {
          dietMatch = diet == 'vegan';
        } else if (_selectedDiet == 'Vegetarian') {
          dietMatch = diet == 'vegan' || diet == 'vegetarian';
        } else if (_selectedDiet == 'Pescatarian') {
          dietMatch =
              diet == 'vegan' || diet == 'vegetarian' || diet == 'pescatarian';
        } else {
          dietMatch = diet == _selectedDiet.toLowerCase();
        }

        // Category check
        final categoryMatch =
            _selectedCategory == 'All' ||
            (food.category?.toLowerCase() == _selectedCategory.toLowerCase());

        // Search check (redundant but safe if we didn't use search endpoint)
        final name = food.name?.toLowerCase() ?? '';
        final desc = food.description?.toLowerCase() ?? '';
        final queryMatch =
            _searchQuery.isEmpty ||
            name.contains(_searchQuery) ||
            desc.contains(_searchQuery);

        return dietMatch && categoryMatch && queryMatch;
      }).toList();

      setState(() {
        _filteredFoods = refinedList;
      });
    } catch (e) {
      debugPrint('Error fetching foods: $e');
    } finally {
      setState(() => _isLoading = false);
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

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchFoods();
  }

  void _showFilterBottomSheet(double scale, double h, double w) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryColor,
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
                          color: Colors.white,
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                  Gap(16 * h),
                  Wrap(
                    spacing: 8 * w,
                    runSpacing: 8 * h,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedCategory = category;
                          });
                          _onCategoryChanged(category);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * w,
                            vertical: 10 * h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarayColor
                                : AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primarayColor
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.black : Colors.white70,
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
                  Gap(24 * h),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(80 * h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * w),
          child: Text(
            'Search Meals',
            style: GoogleFonts.inter(
              color: Colors.white,
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
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 14 * scale,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _onFilterChanged(diet),
                  selectedColor: AppColors.primarayColor,
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primarayColor
                          : AppColors.secondaryColor,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        if (_selectedCategory != 'All') ...[
          Gap(4 * h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * w),
            child: Row(
              children: [
                Text(
                  'Category: ',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 12 * scale,
                  ),
                ),
                GestureDetector(
                  onTap: () => _onCategoryChanged('All'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * w,
                      vertical: 4 * h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarayColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(
                        color: AppColors.primarayColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCategory,
                          style: GoogleFonts.inter(
                            color: AppColors.primarayColor,
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(4 * w),
                        Icon(
                          Icons.close,
                          size: 14 * scale,
                          color: AppColors.primarayColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Gap(12 * h),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: _onRefresh),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 14,
                    ),
                  ),
                )
              else if (_filteredFoods.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(scale, h),
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

  Widget _buildEmptyState(double scale, double h) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80 * scale,
            color: Colors.white24,
          ),
          SizedBox(height: 24 * h),
          Text(
            'No Meals Found',
            style: GoogleFonts.inriaSans(
              color: Colors.white,
              fontSize: 24 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12 * h),
          Text(
            "We couldn't find anything matching your criteria.\nTry adjusting your search or filters.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inriaSans(
              color: Colors.white54,
              fontSize: 16 * scale,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40 * h),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedDiet = 'All';
                _selectedCategory = 'All';
              });
              _fetchFoods();
            },
            icon: Icon(
              Icons.refresh,
              color: AppColors.primarayColor,
              size: 20 * scale,
            ),
            label: Text(
              'Reset Filters',
              style: TextStyle(
                color: AppColors.primarayColor,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primarayColor),
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
