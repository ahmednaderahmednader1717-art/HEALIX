import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_splash/core/app_colors.dart';

class StepProfilePhoto extends StatefulWidget {
  final Function(File?) onImageSelected;
  final File? selectedImage;

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
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.selectedImage;
  }

  @override
  void didUpdateWidget(covariant StepProfilePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedImage?.path != oldWidget.selectedImage?.path) {
      setState(() => _imageFile = widget.selectedImage);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final file = File(picked.path);
      print("Picked image path: ${file.path} - Exists: ${file.existsSync()}");
      if (file.existsSync()) {
        setState(() => _imageFile = file);
        widget.onImageSelected(file);
      } else {
        _showErrorDialog('Selected file does not exist!');
      }
    }
  }


  void _removeImage() {
    setState(() => _imageFile = null);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(40),
          Text(
            "Add a Profile Photo",
            style: GoogleFonts.inriaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Gap(12),
          Text(
            "This step is optional, you can skip if you want.",
            style: GoogleFonts.inriaSans(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const Gap(30),
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[800],
              backgroundImage: (_imageFile != null && _imageFile!.existsSync())
                  ? FileImage(_imageFile!)
                  : null,
              child: (_imageFile == null || !_imageFile!.existsSync())
                  ? Icon(Icons.person, color: Colors.grey[400], size: 60)
                  : null,
            ),
          ),
          const Gap(40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageButton(
                Icons.camera_alt,
                "Camera",
                () => _pickImage(ImageSource.camera),
              ),
              Gap(30),
              _imageButton(
                Icons.photo_library,
                "Gallery",
                () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
          if (_imageFile != null)
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
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: AppColors.primarayColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const Gap(8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
