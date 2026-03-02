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

  final List<String> _dietTypes = [
    'All',
    'Vegan',
    'Vegetarian',
    'Pescatarian',
    'Standard',
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
      if (_selectedDiet != 'All') {
        foods = await _foodService.getFoodsByDiet(_selectedDiet);
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
          child: CustomSearchBar(scale: scale, onChanged: _onSearchChanged),
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
            "We couldn't find anything matching '$_searchQuery'.\nTry adjusting your search criteria.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inriaSans(
              color: Colors.white54,
              fontSize: 16 * scale,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40 * h),
          OutlinedButton.icon(
            onPressed: _fetchFoods,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primarayColor,
              size: 20 * scale,
            ),
            label: Text(
              'Reload Foods',
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
