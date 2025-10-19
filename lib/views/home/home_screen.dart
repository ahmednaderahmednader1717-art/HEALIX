import 'dart:math';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/views/home_tab.dart';
import 'package:test_splash/views/home/views/profile_tab.dart';
import 'package:test_splash/views/home/views/scan_meal_tab.dart';
import 'package:test_splash/views/home/views/search_meal_tab.dart';
import 'package:test_splash/views/home/widgets/home_page_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final UserInfo user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // الصفحات
  late final List<Widget> _pages = [
    HomeTab(
      onTabChange: (index) {
        setState(() => _currentIndex = index);
      },
    ),
    const SearchMealTab(),
    const ScanMealTab(),
    const ProfileTab(),
  ];

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

    return Scaffold(
      backgroundColor: Colors.black,

      // 👇 Stack عشان نضيف AppBar ثابت فوق كل التابات
      body: SafeArea(
        child: Stack(
          children: [
            // محتوى التابات
            IndexedStack(index: _currentIndex, children: _pages),
        
            // AppBar ثابت لكل الصفحات
            HomePageAppBar(
              toolbarHeight: toolbarHeight,
              w: w,
              scale: scale,
              userName: widget.user.fullName,
              
            ),
          ],
        ),
      ),

      // شريط التنقل السفلي
      bottomNavigationBar: CurvedNavigationBar(
        iconPadding: 8,
        backgroundColor: const Color.fromARGB(
          153,
          0,
          0,
          0,
        ).withValues(alpha: 0.60),
        color: AppColors.ContainerColor,
        buttonBackgroundColor: AppColors.primarayColor,
        animationDuration: Duration(milliseconds: 400),
        height: 80,
        items: [
          CurvedNavigationBarItem(
            child: const Icon(Icons.home, color: Colors.white, size: 35),
            label: "Home",
            labelStyle: TextStyle(fontSize: 12 * scale, color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.search, color: Colors.white, size: 35),
            label: "Search Meals",
            labelStyle: TextStyle(fontSize: 12 * scale, color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.camera_alt, color: Colors.white, size: 35),
            label: "Scan Meal",
            labelStyle: TextStyle(fontSize: 12 * scale, color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.person, color: Colors.white, size: 35),
            label: "Profile",
            labelStyle: TextStyle(fontSize: 12 * scale, color: Colors.white),
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
