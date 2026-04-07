import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:test_splash/models/user_info_model.dart';
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

  XFile? _pickedImage;

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _pickedImage = image;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saving picture...')));

      final dio = Dio();

      String fileName = image.name.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      if (fileExtension.isEmpty || fileExtension.length > 4) {
        fileExtension = 'jpg';
      }

      MultipartFile multipartFile;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename:
              "profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension",
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({'file': multipartFile});

      final response = await dio.post(
        'http://healix26.somee.com/api/User/upload-profile-picture',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
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
          try {
            await dio.put(
              'http://healix26.somee.com/api/User/update-profile-picture',
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
          ).showSnackBar(const SnackBar(content: Text('Picture updated!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading picture')),
        );
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
        'http://healix26.somee.com/api/User/update-profile',
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
    final w = screenWidth / 430;

    return Scaffold(
      backgroundColor: const Color(0xFF16313B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22 * w,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20 * w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24 * w, vertical: 20 * w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(20 * w),
            // Profile Picture
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 140 * w,
                    height: 140 * w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white10, width: 2),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (_pickedImage != null ||
                            userProfileImage.isNotEmpty) {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => FullScreenImage(
                                imageUrl: userProfileImage,
                                localPath: _pickedImage?.path,
                                heroTag: "profile_pic",
                              ),
                            ),
                          );
                        }
                      },
                      child: Hero(
                        tag: "profile_pic",
                        child: ClipOval(
                          child: _pickedImage != null
                              ? (kIsWeb
                                    ? Image.network(
                                        _pickedImage!.path,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_pickedImage!.path),
                                        fit: BoxFit.cover,
                                      ))
                              : (userProfileImage.isNotEmpty
                                    ? (kIsWeb
                                          ? Image.network(
                                              'https://corsproxy.io/?${Uri.encodeComponent(userProfileImage)}',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => _buildPlaceholder(),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: userProfileImage,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CupertinoActivityIndicator(),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      _buildPlaceholder(),
                                            ))
                                    : _buildPlaceholder()),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Container(
                      height: 36 * w,
                      width: 36 * w,
                      decoration: const BoxDecoration(
                        color: AppColors.primarayColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18 * w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(12 * w),
            GestureDetector(
              onTap: _changeProfilePicture,
              child: Text(
                "Change Profile Photo",
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 14 * w,
                ),
              ),
            ),
            Gap(40 * w),
            // Fields
            _buildTextField(
              label: "First Name",
              controller: firstNameController,
              hint: "Enter first name",
              scale: w,
            ),
            Gap(16 * w),
            _buildTextField(
              label: "Last Name",
              controller: lastNameController,
              hint: "Enter last name",
              scale: w,
            ),
            Gap(16 * w),
            _buildTextField(
              label: "Username",
              controller: usernameController,
              hint: "Enter username",
              scale: w,
            ),
            Gap(16 * w),
            GestureDetector(
              onTap: _selectDateOfBirth,
              child: AbsorbPointer(
                child: _buildTextField(
                  label: "Date of Birth",
                  controller: TextEditingController(
                    text: selectedDateOfBirth != null
                        ? DateFormat('MMM d, yyyy').format(selectedDateOfBirth!)
                        : "Not set",
                  ),
                  hint: "Select birth date",
                  scale: w,
                ),
              ),
            ),
            Gap(40 * w),
            _buildSaveButton(w),
            Gap(20 * w),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        widget.user.fullName.isNotEmpty
            ? widget.user.fullName[0].toUpperCase()
            : '',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required double scale,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 14 * scale,
          ),
        ),
        const Gap(8),
        HealixTextField(controller: controller, hint: hint ?? ''),
      ],
    );
  }

  Widget _buildSaveButton(double w) {
    return Container(
      width: double.infinity,
      height: 55 * w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * w),
        color: AppColors.primarayColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveChanges,
          borderRadius: BorderRadius.circular(16 * w),
          child: Center(
            child: Text(
              "Save Changes",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18 * w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String? localPath;
  final String heroTag;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    this.localPath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: localPath != null
                    ? (kIsWeb
                          ? Image.network(localPath!, fit: BoxFit.contain)
                          : Image.file(File(localPath!), fit: BoxFit.contain))
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const CupertinoActivityIndicator(
                              color: Colors.white,
                            ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.white),
                      ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
