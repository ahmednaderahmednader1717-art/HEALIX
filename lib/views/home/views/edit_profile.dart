import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:test_splash/widgets/healix_text_field.dart';

class EditProfile extends StatefulWidget {
  final UserInfo user;
  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;

  @override
  void initState() {
    super.initState();

    final names = widget.user.fullName.split(' ');
    firstNameController = TextEditingController(
      text: names.isNotEmpty ? names.first : '',
    );
    lastNameController = TextEditingController(
      text: names.length > 1 ? names.sublist(1).join(' ') : '',
    );
    usernameController = TextEditingController(text: widget.user.username);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileImage = widget.user.profilePictureUrl ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const baseWidth = 430.0;
    const baseHeight = 932.0;

    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);
    
    return Scaffold(
      backgroundColor: AppColors.ContainerColor,
      appBar: AppBar(
        backgroundColor: AppColors.ContainerColor,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inriaSans(color: Colors.white, fontSize: 22 * scale),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24*w, vertical: 16*h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(32*h),
              // صورة البروفايل + زر التعديل
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: userProfileImage.isNotEmpty
                          ? NetworkImage(userProfileImage)
                          : null,
                      child: userProfileImage.isEmpty
                          ? Text(
                              widget.user.fullName.isNotEmpty
                                  ? widget.user.fullName[0].toUpperCase()
                                  : '',
                              style: GoogleFonts.inriaSans(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: change photo
                      },
                      child: Container(
                        height: 32*h,
                        width: 32*w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18*scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10*h),
              Text(
                "Change Photo",
                style: GoogleFonts.inriaSans(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
              Gap(40*h),
              // First Name
              _editField(
                label: "First Name",
                controller: firstNameController,
                hint: "First Name",
              ),
              Gap(16*h),
              // Last Name
              _editField(
                label: "Last Name",
                controller: lastNameController,
                hint: "Last Name",
              ),
              Gap(16*h),
              // Username
              _editField(
                label: "Username",
                controller: usernameController,
                hint: "Username",
              ),
              Gap(40*h),
              HealixPrimaryButton(
                text: "CONTINUE",
                onPressed: () {},
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
              Gap(20*h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inriaSans(
            color: Colors.white.withOpacity(0.45),
            fontSize: 14,
          ),
        ),
          Gap(4),
        HealixTextField(
          controller: controller,
          hint: hint ?? 'Username',
        ),
      ],
    );
  }
}
