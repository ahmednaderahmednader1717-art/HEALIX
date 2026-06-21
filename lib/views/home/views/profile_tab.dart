import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/l10n/app_localizations.dart';
import 'package:test_splash/core/theme/locale_provider.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/views/edit_nutration_goals.dart';
import 'package:test_splash/views/home/views/edit_profile.dart';
import 'package:test_splash/views/home/views/personal_details_page.dart';
import 'package:test_splash/views/home/views/preferences_page.dart';
import 'package:test_splash/views/home/widgets/profile_card_group.dart';
import 'package:test_splash/views/splash/welcome_screen.dart';
import 'package:test_splash/services/auth_service.dart';

// مودل الكارت كما لديك

// الصفحة الرئيسية
class ProfileTab extends ConsumerStatefulWidget {
  final UserInfo user;
  const ProfileTab({super.key, required this.user});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _isLoading = false;

  void _showDeleteAccountDialog() {
    final loc = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(loc.deleteAccountTitle),
        content: Text(loc.deleteAccountConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context); // إغلاق الحوار
              await _performDelete();
            },
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _showErrorDialog(
          "Authentication token not found. Please log in again.",
        );
        return;
      }

      final dio = Dio(BaseOptions(baseUrl: 'http://healix26.somee.com/api'));

      final response = await dio.delete(
        '/User/delete-account',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // حذف البيانات المحلية وتسجيل الخروج
        await AuthService.clearSession();
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        }
      } else {
        _showErrorDialog(
          "Failed to delete account. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLanguageSheet() {
    final currentLang = ref.read(localeNotifierProvider.notifier).currentLanguageName;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectionSheet(
        selectedLanguage: currentLang,
        onLanguageSelected: (lang) {
          ref.read(localeNotifierProvider.notifier).setLocale(lang);
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.clearSession();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final loc = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(loc.error),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const baseWidth = 430.0;
    const baseHeight = 932.0;

    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16 * w, vertical: 16 * h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70 * h),
              Text(
                AppLocalizations.of(context).profile,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 32 * w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24 * h),

              // Profile Card
              ScaleFeedbackWrapper(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => EditProfile(user: widget.user),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(18 * w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.69 : 0.8,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      // فحص وجود الرابط من الـUserInfo قبل العرض
                      Container(
                        width: 60 * scale,
                        height: 60 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surface,
                        ),
                        child: ClipOval(
                          child:
                              (widget.user.profilePictureUrl != null &&
                                  widget.user.profilePictureUrl!.isNotEmpty)
                              ? Builder(
                                  builder: (context) {
                                    String rawUrl =
                                        widget.user.profilePictureUrl!;
                                    String finalUrl = rawUrl.startsWith('http')
                                        ? rawUrl
                                        : 'http://healix26.somee.com${rawUrl.startsWith('/') ? '' : '/'}$rawUrl';

                                    return kIsWeb
                                        ? Image.network(
                                            'https://corsproxy.io/?${Uri.encodeComponent(finalUrl)}',
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  print(
                                                    "❌ Error loading image: $error",
                                                  );
                                                  return Image.asset(
                                                    "assets/logo/person_icon.png",
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return const CupertinoActivityIndicator();
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

                      SizedBox(width: 16 * w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.fullName,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 20 * w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            " @${widget.user.username}",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14 * w,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.onSurfaceVariant,
                        size: 18 * w,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32 * h),

              // Account Section
              Text(
                AppLocalizations.of(context).account,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: AppLocalizations.of(context).personalDetails,
                    icon: Ionicons.person,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            PersonalDetailsPage(user: widget.user),
                      ),
                    ),
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).preferences,
                    icon: FontAwesomeIcons.gears,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const PreferencesPage(),
                      ),
                    ),
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).language,
                    icon: FontAwesomeIcons.language,
                    onTap: _showLanguageSheet,
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).upgradeToFamilyPlan,
                    icon: Ionicons.people_outline,
                    onTap: () => print("Upgrade clicked"),
                  ),
                ],
                w: w,
                h: h,
              ),

              SizedBox(height: 32 * h),

              // Goals & Tracking
              Text(
                AppLocalizations.of(context).goalsAndTracking,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: AppLocalizations.of(context).editNutritionGoals,
                    icon: Ionicons.nutrition_outline,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            EditNutrationGoals(user: widget.user),
                      ),
                    ),
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).trackDailyIntake,
                    icon: Ionicons.trending_up_outline,
                    onTap: () => print("Track Daily Intake clicked"),
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).weightHistory,
                    icon: Ionicons.barbell_outline,
                    onTap: () {},
                  ),
                ],
                w: w,
                h: h,
              ),
              SizedBox(height: 32 * h),

              // Support & Legal
              Text(
                AppLocalizations.of(context).supportAndLegal,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: AppLocalizations.of(context).requestAFeature,
                    icon: Ionicons.bulb_outline,
                    onTap: () => print("Request Feature clicked"),
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).supportEmail,
                    icon: Ionicons.mail_outline,
                    onTap: () => print("Support Email clicked"),
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).syncData,
                    icon: Ionicons.sync_outline,
                    arrow: false,
                    onTap: () {},
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).termsAndConditions,
                    icon: Ionicons.document_text_outline,
                    onTap: () {},
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).privacyPolicy,
                    icon: Ionicons.lock_closed_outline,
                    onTap: () {},
                  ),
                ],
                w: w,
                h: h,
              ),

              SizedBox(height: 32 * h),

              // Follow Us
              Text(
                AppLocalizations.of(context).followUs,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: "Instagram",
                    icon: Ionicons.logo_instagram,
                    onTap: () => print("Edit Nutrition Goals clicked"),
                  ),
                  ProfileCardItem(
                    title: "TikTok",
                    icon: Ionicons.logo_tiktok,
                    onTap: () => print("Track Daily Intake clicked"),
                  ),
                  ProfileCardItem(
                    title: "X",
                    icon: FontAwesomeIcons.xTwitter,
                    onTap: () {},
                  ),
                ],
                w: w,
                h: h,
              ),
              SizedBox(height: 32 * h),

              // Account Actions
              Text(
                AppLocalizations.of(context).accountActions,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: AppLocalizations.of(context).logout,
                    icon: Ionicons.log_out_outline,
                    onTap: _showLogoutDialog,
                  ),
                  ProfileCardItem(
                    title: AppLocalizations.of(context).deleteAccount,
                    icon: Ionicons.person_remove_outline,
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
                w: w,
                h: h,
              ),
              const SizedBox(
                height: kBottomNavigationBarHeight + 40,
              ), // 24 لتعطي مسافة زيادة
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: colorScheme.surface.withValues(alpha: 0.5),
            child: Center(
              child: CupertinoActivityIndicator(
                radius: 15,
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class ScaleFeedbackWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleFeedbackWrapper({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<ScaleFeedbackWrapper> createState() => _ScaleFeedbackWrapperState();
}

class _ScaleFeedbackWrapperState extends State<ScaleFeedbackWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    Future.delayed(const Duration(milliseconds: 20), () {
      widget.onTap();
    });
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────
// Language Selection Bottom Sheet
// ─────────────────────────────────────────────

class _Language {
  final String flag;
  final String name;
  const _Language(this.flag, this.name);
}

const List<_Language> _kLanguages = [
  _Language('🇺🇸', 'English'),
  _Language('🇪🇬', 'العربية'),
  _Language('🇨🇳', '中国人'),
  _Language('🇮🇳', 'हिन्दी'),
  _Language('🇪🇸', 'Español'),
  _Language('🇫🇷', 'Français'),
  _Language('🇩🇪', 'Deutsch'),
  _Language('🇷🇺', 'Русский'),
  _Language('🇧🇷', 'Português'),
  _Language('🇮🇹', 'Italiano'),
  _Language('🇷🇴', 'Română'),
  _Language('🇦🇿', 'Azərbaycanca'),
  _Language('🇳🇱', 'Nederlands'),
  _Language('🇯🇵', '日本語'),
  _Language('🇰🇷', '한국어'),
];

class LanguageSelectionSheet extends StatefulWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  const LanguageSelectionSheet({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<LanguageSelectionSheet> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).selectLanguage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),

          // Language list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _kLanguages.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, index) {
                final lang = _kLanguages[index];
                final isSelected = lang.name == _current;

                return InkWell(
                  onTap: () {
                    setState(() => _current = lang.name);
                    widget.onLanguageSelected(lang.name);
                    Future.delayed(const Duration(milliseconds: 180), () {
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            lang.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}
