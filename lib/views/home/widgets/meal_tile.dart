import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';

class MealTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final int calories;
  final double scale;

  const MealTile({
    required this.imagePath,
    required this.title,
    required this.calories,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Image.asset(
              imagePath,
              width: 110 * scale,
              height: 90 * scale,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
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
                        "$calories kcal",
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
            child:IconButton(onPressed: (){},
              icon: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarayColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.primarayColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * scale,
                  ),
                ),
              ),
              
              ),
              
          ),
        ],
      ),
    );
  }
}
