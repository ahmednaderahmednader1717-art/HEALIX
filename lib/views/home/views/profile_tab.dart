import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/widgets/profile_card_group.dart';
import 'package:test_splash/views/splash/welcome_screen.dart';
import 'package:test_splash/widgets/charts_widget.dart';

// مودل الكارت كما لديك
class ProfileCardItem {
  final String title;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  ProfileCardItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
  });
}

// الصفحة الرئيسية
class ProfileTab extends StatelessWidget {
  final UserInfo user;
  const ProfileTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16 * w, vertical: 16 * h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Container(
              padding: EdgeInsets.all(18 * w),
              decoration: BoxDecoration(
                color: AppColors.ContainerColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30, // غيّر القيمة كما تريد (مثل 64 أو 72)
                    backgroundImage: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(user.profilePictureUrl!)
                    : AssetImage("assets/logo/person_icon.png") as ImageProvider,
                  ),
      
                  SizedBox(width: 16 * w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? "No Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        " @${user.username}",
                        style: TextStyle(color: Colors.grey, fontSize: 14 * w),
                      ),
                    ],
                  ),
                ],
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
                  icon: Ionicons.person_outline,
                  onTap: () => print("Personal Details clicked"),
                ),
                ProfileCardItem(
                  title: "Preferences",
                  icon: Ionicons.options_outline,
                  onTap: () => print("Preferences clicked"),
                ),
                ProfileCardItem(
                  title: "Language",
                  icon: Ionicons.globe_outline,
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
                  onTap: () => print("Track Daily Intake clicked"),
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
    );
  }
}
