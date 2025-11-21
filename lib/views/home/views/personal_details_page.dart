import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';

class PersonalDetailsPage extends StatelessWidget {
  final UserInfo user;
  const PersonalDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // بيانات المشترك (يمكن ربطها ببيانات حقيقية)
    final goalWeight = '${user.userGoalWeight}';
    final currentWeight = '60 kg';
    final height = '180 cm';
    final birthDate = '17/06/2004';
    final gender = 'Male';
    final dailyStepGoal = '10000 steps';

    return Scaffold(
      backgroundColor: AppColors.ContainerColor,
      appBar: AppBar(
        backgroundColor: AppColors.ContainerColor,
        title: Text(
          "Personal Details",
          style: GoogleFonts.inriaSans(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // هدف الوزن بخلفية وعناصر مميزة
            SizedBox(height: 35,),
            Container(
              decoration: BoxDecoration(
                color: AppColors.ContainerColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondaryColor,width: 1)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal Weight',
                          style: GoogleFonts.inriaSans(
                            color: Colors.white.withOpacity(0.73),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          goalWeight,
                          style: GoogleFonts.inriaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      // فعل تغير الهدف
                    },
                    child: Text(
                      'Change Goal',
                      style: GoogleFonts.inriaSans(
                        color: const Color(0xFF232237),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // باقي البيانات في Card مظللة
            Container(
              decoration: BoxDecoration(
                color: AppColors.ContainerColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondaryColor, width: 1)
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
              child: Column(
                children: [
                  _infoRow('Current weight', currentWeight, onEdit: () {}),
                  Divider(
                    color: Colors.grey.withOpacity(0.35),
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow('Height', height, onEdit: () {}),
                    Divider(
                    color: Colors.grey.withOpacity(0.35),
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow('Date of birth', birthDate, onEdit: () {}),
                    Divider(
                    color: Colors.grey.withOpacity(0.35),
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow('Gender', gender, onEdit: () {}),
                    Divider(
                    color: Colors.grey.withOpacity(0.35),
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow('Daily step goal', dailyStepGoal, onEdit: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inriaSans(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inriaSans(
              color: Colors.white,
              fontSize: title == 'Daily step goal' ? 17 : 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 13),
          InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: onEdit,
            child: Icon(
              Icons.edit,
              color: Colors.white.withOpacity(0.57),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}
