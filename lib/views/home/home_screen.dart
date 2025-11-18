import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/views/home_tab.dart';
import 'package:test_splash/views/home/views/profile_tab.dart';
import 'package:test_splash/views/home/views/progress_tab.dart';
import 'package:test_splash/views/home/views/scan_meal_tab.dart';
import 'package:test_splash/views/home/views/search_meal_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final UserInfo user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    HomeTab(
      onTabChange: (index) {
        setState(() => _currentIndex = index);
      },
    ),
    const SearchMealTab(),
    const ScanMealTab(),
    const ProgressTab(),
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

    return Scaffold(
      extendBody: true, // مهم للشفافية
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 48, 6, 21),
                  Color.fromARGB(255, 14, 5, 47),
                  Color.fromARGB(255, 47, 6, 53),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          // محتوى التابات مع padding أسفل BottomNavigationBar
          IndexedStack(
            index: _currentIndex,
            children: _pages.map((page) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 90,
                ),
                child: page,
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 101*h,
                decoration: BoxDecoration(
                  color: AppColors.ContainerColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: BottomNavigationBar(
                  
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  useLegacyColorScheme: false,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 30 * scale),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search, size: 30 * scale),
                      label: "Search",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle, size: 50 * scale),
                      label: "Add",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.insights_sharp, size: 30 * scale),
                      label: "Progress",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, size: 30 * scale),
                      label: "Profile",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
