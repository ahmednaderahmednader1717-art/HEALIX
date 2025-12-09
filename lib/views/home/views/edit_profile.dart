import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/widgets/common/healix_primary_button.dart';
import 'package:test_splash/widgets/common/healix_text_field.dart';

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
  DateTime? selectedDateOfBirth;

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
    selectedDateOfBirth = widget.user.dateOfBirth;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: AppColors.ContainerColor,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.ContainerColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
      });
    }
  }

  // Add this variable to store picked image (Cross-platform)
  XFile? _pickedImage;

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    // ✅ Show local image immediately
    setState(() {
      _pickedImage = image;
    });

    try {
      // Get token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('جاري حفظ الصورة...')));

      // Upload image
      final dio = Dio();

      String fileName = image.name.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      // Default to jpeg if extension is missing or weird
      if (fileExtension.isEmpty || fileExtension.length > 4)
        fileExtension = 'jpg';

      MultipartFile multipartFile;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename:
              "profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension",
          // contentType: MediaType('image', fileExtension), // Requires http_parser, letting Dio infer or server handle it for now to avoid import issues if package missing
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({'file': multipartFile});

      final response = await dio.post(
        'http://healix.somee.com/api/User/upload-profile-picture',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // 'Content-Type': 'multipart/form-data', // Dio sets this automatically
          },
        ),
      );

      // ... rest of upload logic (keep it to update server)
      if (response.statusCode == 200) {
        // We don't need to update UI from URL anymore since we have local file
        // But we still save URL to profile for next login
        String? newImageUrl;
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['imageUrl'] != null) {
            newImageUrl = data['imageUrl'];
          } else if (data['url'] != null)
            newImageUrl = data['url'];
          else if (data['profilePictureUrl'] != null)
            newImageUrl = data['profilePictureUrl'];
        }

        if (newImageUrl != null) {
          widget.user.profilePictureUrl = newImageUrl;
          // Save to profile API
          try {
            await dio.put(
              'http://healix.somee.com/api/User/update-profile-picture', // Fixed endpoint from Auth to User based on API spec if needed, but spec says /User/update-profile-picture
              data: {'profilePictureUrl': newImageUrl},
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              ),
            );
          } catch (e) {
            print("Error updating profile picture URL: $e");
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تم تحديث الصورة!')));
        }
      } else {
        print("Upload failed: ${response.statusCode} - ${response.data}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل رفع الصورة: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء رفع الصورة')));
      }
    }
  }

  Future<void> _saveChanges() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final fullName = "$firstName $lastName";

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final dio = Dio();
      final response = await dio.put(
        'http://healix.somee.com/api/User/update-profile',
        data: {'fullName': fullName, 'username': username},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.user.fullName = fullName;
          widget.user.username = username;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
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
          style: GoogleFonts.inriaSans(
            color: Colors.white,
            fontSize: 22 * scale,
          ),
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
          padding: EdgeInsets.symmetric(horizontal: 24 * w, vertical: 16 * h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(32 * h),
              // Profile Picture
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade800,
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? (kIsWeb
                                  ? Image.network(
                                      _pickedImage!.path,
                                      fit: BoxFit.cover,
                                      width: 140,
                                      height: 140,
                                    )
                                  : Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.cover,
                                      width: 140,
                                      height: 140,
                                    ))
                            : (userProfileImage.isNotEmpty
                                  ? (kIsWeb
                                        ? Image.network(
                                            'https://corsproxy.io/?${Uri.encodeComponent(userProfileImage)}',
                                            fit: BoxFit.cover,
                                            width: 140,
                                            height: 140,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Center(
                                                    child: Text(
                                                      widget
                                                              .user
                                                              .fullName
                                                              .isNotEmpty
                                                          ? widget
                                                                .user
                                                                .fullName[0]
                                                                .toUpperCase()
                                                          : '',
                                                      style:
                                                          GoogleFonts.inriaSans(
                                                            color: Colors.white,
                                                            fontSize: 40,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  );
                                                },
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: userProfileImage,
                                            fit: BoxFit.cover,
                                            width: 140,
                                            height: 140,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) {
                                              return Center(
                                                child: Text(
                                                  widget
                                                          .user
                                                          .fullName
                                                          .isNotEmpty
                                                      ? widget.user.fullName[0]
                                                            .toUpperCase()
                                                      : '',
                                                  style: GoogleFonts.inriaSans(
                                                    color: Colors.white,
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            },
                                          ))
                                  : Center(
                                      child: Text(
                                        widget.user.fullName.isNotEmpty
                                            ? widget.user.fullName[0]
                                                  .toUpperCase()
                                            : '',
                                        style: GoogleFonts.inriaSans(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )),
                      ),
                    ),
                    GestureDetector(
                      onTap: _changeProfilePicture,
                      child: Container(
                        height: 32 * h,
                        width: 32 * w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18 * scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10 * h),
              GestureDetector(
                onTap: _changeProfilePicture,
                child: Text(
                  "Change Photo",
                  style: GoogleFonts.inriaSans(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),
              ),
              Gap(40 * h),
              // First Name
              _buildTextField(
                label: "First Name",
                controller: firstNameController,
                hint: "First Name",
              ),
              Gap(16 * h),
              // Last Name
              _buildTextField(
                label: "Last Name",
                controller: lastNameController,
                hint: "Last Name",
              ),
              Gap(16 * h),
              // Username
              _buildTextField(
                label: "Username",
                controller: usernameController,
                hint: "Username",
              ),
              // Date of Birth
              Gap(40 * h),
              HealixPrimaryButton(
                text: "SAVE",
                onPressed: _saveChanges,
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
              Gap(20 * h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
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
        const Gap(4),
        HealixTextField(controller: controller, hint: hint ?? 'Username'),
      ],
    );
  }
}
