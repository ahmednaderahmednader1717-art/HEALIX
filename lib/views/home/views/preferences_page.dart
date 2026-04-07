import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/services/notification_service.dart';
import 'package:test_splash/services/live_activity_service.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _waterRemindersEnabled = false;
  bool _streakRemindersEnabled = true;
  bool _liveActivitiesEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterRemindersEnabled =
          prefs.getBool('water_reminders_enabled') ?? false;
      _streakRemindersEnabled =
          prefs.getBool('streak_reminders_enabled') ?? true;
      _liveActivitiesEnabled = prefs.getBool('live_activities_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleWaterReminders(bool value) async {
    setState(() => _waterRemindersEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminders_enabled', value);
    if (value) {
      await LocalNotificationService.scheduleWaterReminders();
    } else {
      await LocalNotificationService.cancelWaterReminders();
    }
  }

  Future<void> _toggleStreakReminders(bool value) async {
    setState(() => _streakRemindersEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streak_reminders_enabled', value);
  }

  Future<void> _toggleLiveActivities(bool value) async {
    setState(() => _liveActivitiesEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('live_activities_enabled', value);
    if (!value) {
      await LiveActivityService.stopActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final w = screenWidth / 430.0;

    return Scaffold(
      backgroundColor: const Color(0xFF16313B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Preferences",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22 * w,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 16 * w),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40 * w,
                height: 40 * w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20 * w,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * w,
                vertical: 10 * w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Appearance",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20 * w,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Choose light, dark, or system appearance",
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 14 * w,
                          ),
                        ),
                        SizedBox(height: 20 * w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAppearanceOption(
                              "System",
                              Ionicons.contrast_outline,
                              w,
                            ),
                            _buildAppearanceOption(
                              "Light",
                              Ionicons.sunny_outline,
                              w,
                            ),
                            _buildAppearanceOption(
                              "Dark",
                              Ionicons.moon_outline,
                              w,
                              isSelected: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    w: w,
                  ),
                  SizedBox(height: 16 * w),

                  // Notifications Section
                  _buildSectionContainer(
                    child: Column(
                      children: [
                        _buildPreferenceItem(
                          title: "Water reminders",
                          subtitle:
                              "Get notified 8 times daily to stay hydrated",
                          value: _waterRemindersEnabled,
                          onChanged: _toggleWaterReminders,
                          w: w,
                        ),
                        _buildDivider(w),
                        _buildPreferenceItem(
                          title: "Streak reminders",
                          subtitle: "Remind me to log food at 8 PM",
                          value: _streakRemindersEnabled,
                          onChanged: _toggleStreakReminders,
                          w: w,
                        ),
                        _buildDivider(w),
                        _buildPreferenceItem(
                          title: "Badge celebrations",
                          subtitle:
                              "Show a full-screen badge animation when you unlock a new badge",
                          value: true,
                          onChanged: (v) {},
                          w: w,
                        ),
                        _buildDivider(w),
                        _buildPreferenceItem(
                          title: "Live activity",
                          subtitle:
                              "Show your daily calories and macros on your lock screen",
                          value: _liveActivitiesEnabled,
                          onChanged: _toggleLiveActivities,
                          w: w,
                        ),
                      ],
                    ),
                    w: w,
                  ),

                  SizedBox(height: 16 * w),

                  // Units Section
                  _buildSectionContainer(
                    child: _buildPreferenceItem(
                      title: "Auto adjust macros",
                      subtitle:
                          "Automatically adjust other values proportionally when editing macros",
                      value: true,
                      onChanged: (v) {},
                      w: w,
                    ),
                    w: w,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionContainer({required Widget child, required double w}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * w),
      decoration: BoxDecoration(
        color: AppColors.ContainerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28 * w),
      ),
      child: child,
    );
  }

  Widget _buildAppearanceOption(
    String label,
    IconData icon,
    double w, {
    bool isSelected = false,
  }) {
    return Column(
      children: [
        Container(
          width: 100 * w,
          height: 80 * w,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16 * w),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white38,
              size: 32 * w,
            ),
          ),
        ),
        SizedBox(height: 8 * w),
        Row(
          children: [
            Icon(
              isSelected ? Ionicons.radio_button_on : Ionicons.radio_button_off,
              color: isSelected ? Colors.white : Colors.white38,
              size: 16 * w,
            ),
            SizedBox(width: 4 * w),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 16 * w,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double w,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 19 * w,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2 * w),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 13 * w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * w),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF4CD964), // Green as per image
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double w) {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.white.withOpacity(0.05),
    );
  }
}
