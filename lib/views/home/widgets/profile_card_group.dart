// مجموعة كروت متلاصقة وقابلة للنقر
import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/home/views/profile_tab.dart';

class ProfileCardGroup extends StatelessWidget {
  final List<ProfileCardItem> items;
  final double w, h;

  const ProfileCardGroup({
    super.key,
    required this.items,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (i) {
        return InkWell(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(i == 0 ? 20 : 0),
            bottom: Radius.circular(i == items.length - 1 ? 20 : 0),
          ),
          onTap: items[i].onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.ContainerColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(i == 0 ? 20 : 0),
                bottom: Radius.circular(i == items.length - 1 ? 20 : 0),
              ),
            ),
            child: _buildCard(items[i], w, h),
          ),
        );
      }),
    );
  }

  Widget _buildCard(ProfileCardItem item, double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18 * h, horizontal: 18 * w),
      child: Row(
        children: [
          Icon(item.icon, color: Colors.white, size: 24 * w),
          SizedBox(width: 16 * w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * w,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.subtitle!,
                      style: TextStyle(color: Colors.grey, fontSize: 13 * w),
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18 * w),
        ],
      ),
    );
  }
}
