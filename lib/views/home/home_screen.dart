import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/views/home_tab.dart';
import 'package:test_splash/l10n/app_localizations.dart';
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

    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            if (theme.brightness == Brightness.dark)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF000D11), Color(0xFF022836)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            IndexedStack(index: _currentIndex, children: _pages),
          ],
        ),
        bottomNavigationBar: !kIsWeb && Platform.isIOS
            ? _buildIOSTabBar(theme)
            : _buildDefaultTabBar(scale, h),
      ),
    );
  }

  // iOS Tab Bar with cupertino_native package
  Widget _buildIOSTabBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        child: CupertinoTheme(
          data: CupertinoThemeData(brightness: theme.brightness),
          child: CNTabBar(
            height: 90,
            tint: isDark ? const Color.fromARGB(255, 141, 215, 225) : theme.colorScheme.primary,
            items: [
              CNTabBarItem(label: AppLocalizations.of(context).home, icon: CNSymbol('house.fill')),
              CNTabBarItem(label: AppLocalizations.of(context).search, icon: CNSymbol('magnifyingglass')),
              CNTabBarItem(label: AppLocalizations.of(context).scan, icon: CNSymbol('plus.circle.fill')),
              CNTabBarItem(label: AppLocalizations.of(context).progress, icon: CNSymbol('chart.bar.fill')),
              CNTabBarItem(
                label: AppLocalizations.of(context).profile,
                icon: CNSymbol('person.crop.circle'),
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
        ),
      ),
    );
  }

  // Default Tab Bar for Android/Web
  Widget _buildDefaultTabBar(double scale, double h) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF16313B).withValues(alpha: 0.4)
                    : colorScheme.surface.withValues(alpha: 0.8),
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
                  selectedItemColor: isDark ? Colors.white : colorScheme.primary,
                  unselectedItemColor: isDark ? Colors.white54 : colorScheme.onSurface.withValues(alpha: 0.5),
                  selectedFontSize: 12,
                  unselectedFontSize: 10,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  useLegacyColorScheme: false,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 30 * scale),
                      label: AppLocalizations.of(context).home,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search, size: 30 * scale),
                      label: AppLocalizations.of(context).search,
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
                      label: AppLocalizations.of(context).progress,
                    ),
                    BottomNavigationBarItem(
                      // CircleAvatar صورة المستخدم في التاب الخامس (Profile)
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                          ),
                          child: ClipOval(
                            child: (user.profilePictureUrl != null &&
                                    user.profilePictureUrl!.isNotEmpty)
                                ? Builder(
                                    builder: (context) {
                                      String rawUrl = user.profilePictureUrl!;
                                      String finalUrl = rawUrl.startsWith('http')
                                          ? rawUrl
                                          : 'http://healix26.somee.com${rawUrl.startsWith('/') ? '' : '/'}$rawUrl';

                                      return kIsWeb
                                          ? Image.network(
                                              'https://corsproxy.io/?${Uri.encodeComponent(finalUrl)}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  "assets/logo/person_icon.png",
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: finalUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CupertinoActivityIndicator(),
                                              errorWidget: (context, url, error) {
                                                return Image.asset(
                                                  "assets/logo/person_icon.png",
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            );
                                    },
                                  )
                                : Image.asset(
                                    "assets/logo/person_icon.png",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      label: AppLocalizations.of(context).profile,
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
