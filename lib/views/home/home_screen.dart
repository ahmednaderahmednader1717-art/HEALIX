import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
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

  late UserInfo user; // لإتاحة التحديث إذا تغيرت الصورة لاحقًا

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  late final List<Widget> _pages = [
    HomeTab(
      onTabChange: (index) {
        setState(() => _currentIndex = index);
      },
    ),
    const SearchMealTab(),
    const ScanMealTab(),
    const ProgressTab(),
    ProfileTab(user: user),
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

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        extendBody: true,
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
            IndexedStack(index: _currentIndex, children: _pages),
          ],
        ),
        bottomNavigationBar: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.ContainerColor.withOpacity(0.4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      right: 8.0,
                      left: 8.0,
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (index) => setState(() => _currentIndex = index),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.white54,
                      selectedFontSize: 12,
                      unselectedFontSize: 10,
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
                          icon: Padding(
                            padding: EdgeInsets.only(top: 15 * h),
                            child: Icon(Icons.add_circle, size: 55 * scale),
                          ),
                          label: "",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.insights_sharp, size: 30 * scale),
                          label: "Progress",
                        ),
                        BottomNavigationBarItem(
                          // CircleAvatar صورة المستخدم في التاب الخامس (Profile)
                          icon: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[800],
                              ),
                              child: ClipOval(
                                child:
                                    (user.profilePictureUrl != null &&
                                        user.profilePictureUrl!.isNotEmpty)
                                    ? (kIsWeb
                                          ? Image.network(
                                              'https://corsproxy.io/?${Uri.encodeComponent(user.profilePictureUrl!)}',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Image.asset(
                                                      "assets/logo/person_icon.png",
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: user.profilePictureUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CupertinoActivityIndicator(),
                                              errorWidget: (context, url, error) {
                                                return Image.asset(
                                                  "assets/logo/person_icon.png",
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ))
                                    : Image.asset(
                                        "assets/logo/person_icon.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          label: "Profile",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
