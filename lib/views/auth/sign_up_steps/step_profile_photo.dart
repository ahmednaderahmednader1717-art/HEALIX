import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:test_splash/core/app_colors.dart';

class StepProfilePhoto extends StatefulWidget {
  final Function(dynamic)
  onImageSelected; // dynamic: File (mobile) أو Uint8List (web)
  final dynamic selectedImage; // File أو Uint8List

  const StepProfilePhoto({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
  });

  @override
  State<StepProfilePhoto> createState() => _StepProfilePhotoState();
}

class _StepProfilePhotoState extends State<StepProfilePhoto> {
  File? _imageFile;
  Uint8List? _imageBytes;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (UniversalPlatform.isWeb &&
        widget.selectedImage != null &&
        widget.selectedImage is Uint8List) {
      _imageBytes = widget.selectedImage;
    } else if (widget.selectedImage != null && widget.selectedImage is File) {
      _imageFile = widget.selectedImage;
    }
  }

  @override
  void didUpdateWidget(covariant StepProfilePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (UniversalPlatform.isWeb &&
        widget.selectedImage != null &&
        widget.selectedImage is Uint8List) {
      setState(() => _imageBytes = widget.selectedImage);
    } else if (widget.selectedImage != null && widget.selectedImage is File) {
      setState(() => _imageFile = widget.selectedImage);
    }
  }

  Future<void> _pickImageMobile(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final file = File(picked.path);
      if (file.existsSync()) {
        setState(() => _imageFile = file);
        widget.onImageSelected(file);
      } else {
        _showErrorDialog('Selected file does not exist!');
      }
    }
  }

  Future<void> _pickImageWeb() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      Uint8List? imageBytes = result.files.first.bytes;
      if (imageBytes != null) {
        setState(() => _imageBytes = imageBytes);
        widget.onImageSelected(imageBytes);
      } else {
        _showErrorDialog('No image bytes found!');
      }
    } else {
      _showErrorDialog('No image selected!');
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageBytes = null;
    });
    widget.onImageSelected(null);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget? avatarChild;
    ImageProvider? avatarBG;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // مقاسات التصميم الأصلية (iPhone 14 Pro Max)
    const baseWidth = 430.0;
    const baseHeight = 932.0;

    // نسب التناسب
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h); // 👈 المفتاح لتصميم متناسق على كل الشاشات


    if (UniversalPlatform.isWeb) {
      // web
      if (_imageBytes != null) {
        avatarBG = MemoryImage(_imageBytes!);
        avatarChild = null;
      } else {
        avatarBG = null;
        avatarChild = Icon(Icons.person, color: Colors.grey[400], size: 60*scale);
      }
    } else {
      // mobile
      if (_imageFile != null && _imageFile!.existsSync()) {
        avatarBG = FileImage(_imageFile!);
        avatarChild = null;
      } else {
        avatarBG = null;
        avatarChild = Icon(Icons.person, color: Colors.grey[400], size: 60*scale);
      }
    }

    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 24*w, vertical: 12*h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(40*h),
          Text(
            "Add a Profile Photo",
            style: GoogleFonts.inriaSans(
              fontSize: 20*scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
            Gap(12*h),
          Text(
            "This step is optional, you can skip if you want.",
            style: GoogleFonts.inriaSans(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
            Gap(30*h),
          Center(
            child: CircleAvatar(
              radius: 70*scale,
              backgroundColor: Colors.grey[800],
              backgroundImage: avatarBG,
              child: avatarChild,
            ),
          ),
          Gap(40*h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageButton(Icons.camera_alt, "Camera", () {
                if (UniversalPlatform.isWeb) {
                  _pickImageWeb();
                } else {
                  _pickImageMobile(ImageSource.camera);
                }
              }),
              Gap(30*h),
              _imageButton(Icons.photo_library, "Gallery", () {
                if (UniversalPlatform.isWeb) {
                  _pickImageWeb();
                } else {
                  _pickImageMobile(ImageSource.gallery);
                }
              }),
            ],
          ),
          if (_imageFile != null || _imageBytes != null)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: TextButton(
                onPressed: _removeImage,
                child: const Text(
                  "Remove Photo",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageButton(IconData icon, String label, VoidCallback onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // مقاسات التصميم الأصلية (iPhone 14 Pro Max)
    const baseWidth = 430.0;
    const baseHeight = 932.0;

    // نسب التناسب
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h); // 👈 المفتاح لتصميم متناسق على كل الشاشات

    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 65*h,
            width: 65*w,
            decoration: BoxDecoration(
              color: AppColors.primarayColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28*scale),
          ),
        ),
        Gap(8*h),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 13*scale),
        ),
      ],
    );
  }
}
