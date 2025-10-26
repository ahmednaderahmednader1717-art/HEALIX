import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/auth/sign_up_steps/StepPersonalInfo.dart';
import 'package:test_splash/views/auth/sign_up_steps/step_body_type.dart';
import 'package:test_splash/views/auth/sign_up_steps/step_diet_type.dart';
import 'package:test_splash/views/auth/sign_up_steps/stepaccountinfo.dart';
import 'package:test_splash/views/auth/sign_up_steps/stepextradetails.dart';
import 'package:test_splash/views/auth/sign_up_steps/steppassword.dart';
import 'package:test_splash/views/auth/sign_up_steps/step_profile_photo.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:gap/gap.dart';

class MultiStepSignUpPage extends StatefulWidget {
  const MultiStepSignUpPage({super.key});

  @override
  State<MultiStepSignUpPage> createState() => _MultiStepSignUpPageState();
}

class _MultiStepSignUpPageState extends State<MultiStepSignUpPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7; // أضفنا خطوة الصورة الجديدة

  // Text Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State variables
  String? _selectedGender;
  DateTime? _selectedDate;
  int? _selectedHeight;
  int? _selectedWeight;
  int? _selectedGoalWeight;
  String? _selectedBodyType;
  String? _selectedDietType;
  File? _profileImage;

  bool _isLoading = false;

  // Error messages
  String? _fullNameError;
  String? _phoneError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _genderError;
  String? _dobError;
  String? _heightError;
  String? _weightError;
  String? _goalWeightError;
  String? _bodyTypeError;
  String? _dietTypeError;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://healix.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  // Validation methods
  bool _validateStep1() {
    setState(() {
      _fullNameError = null;
      _phoneError = null;
    });
    if (_fullNameController.text.trim().isEmpty) {
      _fullNameError = "Full name is required";
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _phoneError = "Phone number is required";
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    setState(() {
      _emailError = null;
      _usernameError = null;
    });
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains("@")) {
      _emailError = "Enter a valid email";
      return false;
    }
    if (_userNameController.text.trim().isEmpty) {
      _usernameError = "Username is required";
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });
    if (_passwordController.text.isEmpty) {
      _passwordError = "Password is required";
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = "Please re-enter password";
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordError = "Passwords do not match";
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    setState(() {
      _genderError = null;
      _dobError = null;
      _heightError = null;
      _weightError = null;
      _goalWeightError = null;
    });
    if (_selectedGender == null) {
      _genderError = "Select your gender";
      return false;
    }
    if (_selectedDate == null) {
      _dobError = "Select your birth date";
      return false;
    }
    if (_selectedHeight == null) {
      _heightError = "Select your height";
      return false;
    }
    if (_selectedWeight == null) {
      _weightError = "Select your weight";
      return false;
    }
    if (_selectedGoalWeight == null) {
      _goalWeightError = "Select your goal weight";
      return false;
    }
    return true;
  }

  bool _validateStepBodyType() {
    if (_selectedBodyType == null || _selectedBodyType!.isEmpty) {
      _bodyTypeError = "Please select your body type";
      return false;
    }
    return true;
  }

  bool _validateStepDietType() {
    if (_selectedDietType == null || _selectedDietType!.isEmpty) {
      _dietTypeError = "Please select your diet type";
      return false;
    }
    return true;
  }

  void _nextPage() async {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;
    if (_currentStep == 2 && !_validateStep3()) return;
    if (_currentStep == 3 && !_validateStep4()) return;
    if (_currentStep == 4 && !_validateStepBodyType()) return;
    if (_currentStep == 5 && !_validateStepDietType()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _signUp();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        "username": _userNameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "fullName": _fullNameController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "dateOfBirth": _selectedDate?.toIso8601String(),
        "gender": _selectedGender,
        "bodyType": _selectedBodyType,
        "dietType": _selectedDietType,
        "height": _selectedHeight,
        "weight": _selectedWeight,
        "goalWeight": _selectedGoalWeight,
        if (_profileImage != null)
          "profilePictureUrl": await MultipartFile.fromFile(
            _profileImage!.path,
            filename: _profileImage!.path.split('/').last,
          ),
      });

      final response = await _dio.post("/Auth/signup", data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              user: UserInfo(
                username: _userNameController.text.trim(),
                email: _emailController.text.trim(),
                fullName: _fullNameController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                dateOfBirth: _selectedDate,
                gender: _selectedGender,
              ),
            ),
          ),
        );
      } else {
        _showDialog("Unexpected server response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      String message = "Something went wrong";
      if (e.response?.data is Map && e.response?.data["message"] != null) {
        message = e.response?.data["message"];
      }
      _showDialog(message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Attention"),
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

  Future<void> _pickDate(BuildContext context) async {
    DateTime initial = _selectedDate ?? DateTime(2000, 1, 1);
    DateTime tempPicked = initial;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => _buildCupertinoPickerContainer(
        child: CupertinoDatePicker(
          backgroundColor: Colors.black,
          mode: CupertinoDatePickerMode.date,
          initialDateTime: initial,
          maximumYear: DateTime.now().year,
          minimumYear: 1900,
          onDateTimeChanged: (newDate) => tempPicked = newDate,
        ),
        onDone: () => setState(() => _selectedDate = tempPicked),
      ),
    );
  }

  Future<void> _pickIntValue(
    BuildContext context,
    String label,
    int min,
    int max,
    int? initialValue,
    Function(int) onSelected,
  ) async {
    int tempValue = initialValue ?? min;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => _buildCupertinoPickerContainer(
        child: CupertinoPicker(
          itemExtent: 45,
          backgroundColor: Colors.black,
          scrollController: FixedExtentScrollController(
            initialItem: (initialValue ?? min) - min,
          ),
          onSelectedItemChanged: (index) {
            tempValue = min + index;
          },
          children: List.generate(
            max - min + 1,
            (i) => Center(
              child: Text(
                "${min + i}",
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
        ),
        onDone: () => onSelected(tempValue),
      ),
    );
  }

  Widget _buildCupertinoPickerContainer({
    required Widget child,
    required VoidCallback onDone,
  }) {
    return Container(
      height: 320,
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDone();
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(color: AppColors.primarayColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width / 430;
    final h = MediaQuery.of(context).size.height / 932;
    final scale = min(w, h);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: const Text(
            "Complete Sign Up",
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Gap(20 * h),
                _progressBar(),
                Expanded(child: _buildPages()),
                _navigationButtons(scale, w, h),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primarayColor
                    : AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPages() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StepPersonalInfo(
          nameController: _fullNameController,
          phoneController: _phoneController,
          nameError: _fullNameError,
          phoneError: _phoneError,
        ),
        StepAccountInfo(
          emailController: _emailController,
          usernameController: _userNameController,
          emailError: _emailError,
          usernameError: _usernameError,
        ),
        StepPassword(
          passwordController: _passwordController,
          confirmController: _confirmPasswordController,
          passwordError: _passwordError,
          confirmError: _confirmPasswordError,
        ),
        StepExtraDetails(
          selectedGender: _selectedGender,
          genderError: _genderError,
          selectedDate: _selectedDate,
          dobError: _dobError,
          selectedHeight: _selectedHeight,
          heightError: _heightError,
          selectedWeight: _selectedWeight,
          weightError: _weightError,
          selectedGoalWeight: _selectedGoalWeight,
          goalWeightError: _goalWeightError,
          onSelectGender: (g) => setState(() => _selectedGender = g),
          onSelectDate: (ctx) async => await _pickDate(ctx),
          onSelectHeight: (ctx) async => await _pickIntValue(
            ctx,
            "Height",
            120,
            220,
            _selectedHeight,
            (v) => setState(() => _selectedHeight = v),
          ),
          onSelectWeight: (ctx) async => await _pickIntValue(
            ctx,
            "Weight",
            30,
            200,
            _selectedWeight,
            (v) => setState(() => _selectedWeight = v),
          ),
          onSelectGoalWeight: (ctx) async => await _pickIntValue(
            ctx,
            "Goal weight",
            30,
            200,
            _selectedGoalWeight,
            (v) => setState(() => _selectedGoalWeight = v),
          ),
        ),
        StepBodyType(
          selectedBodyType: _selectedBodyType,
          errorText: _bodyTypeError,
          onSelect: (bt) => setState(() => _selectedBodyType = bt),
        ),
        StepDietType(
          selectedDietType: _selectedDietType,
          errorText: _dietTypeError,
          onSelect: (dt) => setState(() => _selectedDietType = dt),
        ),
        StepProfilePhoto(
          selectedImage: _profileImage,
          onImageSelected: (file) => setState(() => _profileImage = file),
        ),
      ],
    );
  }

  Widget _navigationButtons(double scale, double w, double h) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Gap(20 * w),
          HealixPrimaryButton.iconOnly(
            leading: Icon(
              _currentStep > 0 ? Icons.arrow_back : Icons.close,
              color: Colors.white,
              size: 30 * scale,
            ),
            onPressed: _currentStep > 0
                ? _previousPage
                : () => Navigator.pop(context),
            width: 60 * w,
            height: 60 * h,
            borderRadius: 999,
            backgroundColor: AppColors.primarayColor.withOpacity(0.4),
          ),
          Gap(20 * w),
          HealixPrimaryButton(
            height: 60,
            width: 300 * w,
            text: _currentStep == _totalSteps - 1 ? "Finish" : "Next Step",
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }
}
