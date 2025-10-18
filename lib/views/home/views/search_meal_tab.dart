import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:test_splash/views/home/widgets/custom_search_bar.dart';
import 'package:test_splash/views/home/widgets/meal_tile.dart';

class SearchMealTab extends StatelessWidget {
  const SearchMealTab({super.key});

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


    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16 * w,
            right: 16 * w,
            top: toolbarHeight+10*h,
            bottom: 120 * h,
          ),
          child: Column(
            children: [
              Gap(20*h),
              CustomSearchBar(scale: scale),
              Gap(30*h),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 12 * h),
                itemBuilder: (context, index) {
                  final image = index.isEven
                      ? "assets/covers/IMG_1049.JPG"
                      : "assets/covers/IMG_1050.PNG";
                  return MealTile(
                    imagePath: image,
                    title: "High Protein Bowl",
                    calories: 420,
                    scale: scale,
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
