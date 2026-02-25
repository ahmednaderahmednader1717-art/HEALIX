import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/views/edit_profile.dart';
import 'package:test_splash/views/home/views/personal_details_page.dart';
import 'package:test_splash/views/home/widgets/profile_card_group.dart';
import 'package:test_splash/views/splash/welcome_screen.dart';

// مودل الكارت كما لديك

// الصفحة الرئيسية
class ProfileTab extends StatefulWidget {
  final UserInfo user;
  const ProfileTab({super.key, required this.user});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    // إظهار حوار التأكيد
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context); // إغلاق الحوار
              await _performDelete();
            },
            child: const Text("Delete"),
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
        await prefs.clear();
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

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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

    return Stack(
      children: [
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16 * w, vertical: 16 * h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70 * h),
              Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32 * w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24 * h),

              // Profile Card
              GestureDetector(
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
                    color: AppColors.ContainerColor,
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
                          color: Colors.grey[800],
                        ),
                        child: ClipOval(
                          child:
                              (widget.user.profilePictureUrl != null &&
                                  widget.user.profilePictureUrl!.isNotEmpty)
                              ? (kIsWeb
                                    ? Image.network(
                                        // CORS Proxy for development only
                                        'https://corsproxy.io/?${Uri.encodeComponent(widget.user.profilePictureUrl!)}',
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
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const CupertinoActivityIndicator();
                                            },
                                      )
                                    : CachedNetworkImage(
                                        imageUrl:
                                            widget.user.profilePictureUrl!,
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

                      SizedBox(width: 16 * w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.fullName ?? "No Name",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20 * w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            " @${widget.user.username}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14 * w,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 18 * w,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32 * h),

              // Account Section
              Text(
                "Account",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: "Personal Details",
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
                    title: "Preferences",
                    icon: FontAwesomeIcons.gears,
                    onTap: () => print("Preferences clicked"),
                  ),
                  ProfileCardItem(
                    title: "Language",
                    icon: FontAwesomeIcons.language,
                    onTap: () => print("Language clicked"),
                  ),
                  ProfileCardItem(
                    title: "Upgrade to Family Plan",
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
                "Goals & Tracking",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: "Edit Nutrition Goals",
                    icon: Ionicons.nutrition_outline,
                    onTap: () => print("Edit Nutrition Goals clicked"),
                  ),
                  ProfileCardItem(
                    title: "Track Daily Intake",
                    icon: Ionicons.trending_up_outline,
                    onTap: () => print("Track Daily Intake clicked"),
                  ),
                  ProfileCardItem(
                    title: "Weight History",
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
                "Support & Legal",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: "Request a Feature",
                    icon: Ionicons.bulb_outline,
                    onTap: () => print("Request Feature clicked"),
                  ),
                  ProfileCardItem(
                    title: "Support Email",
                    icon: Ionicons.mail_outline,
                    onTap: () => print("Support Email clicked"),
                  ),
                  ProfileCardItem(
                    title: "Sync Data",
                    icon: Ionicons.sync_outline,
                    arrow: false,
                    onTap: () {},
                  ),
                  ProfileCardItem(
                    title: "Terms & Conditions",
                    icon: Ionicons.document_text_outline,
                    onTap: () {},
                  ),
                  ProfileCardItem(
                    title: "Privacy Policy",
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
                "Follow Us",
                style: TextStyle(
                  color: Colors.grey[300],
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
                "Account Actions",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16 * w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12 * h),

              ProfileCardGroup(
                items: [
                  ProfileCardItem(
                    title: "Logout",
                    icon: Ionicons.log_out_outline,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    ),
                  ),
                  ProfileCardItem(
                    title: "Delete Account",
                    icon: Ionicons.person_remove_outline,
                    onTap: _deleteAccount,
                  ),
                ],
                w: w,
                h: h,
              ),
              SizedBox(
                height: kBottomNavigationBarHeight + 40,
              ), // 24 لتعطي مسافة زيادة
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CupertinoActivityIndicator(radius: 15)),
          ),
      ],
    );
  }
}
