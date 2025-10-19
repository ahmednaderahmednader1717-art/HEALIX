import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:test_splash/widgets/healix_text_field.dart';

class MultiStepSignUpPage extends StatefulWidget {
  const MultiStepSignUpPage({super.key});

  @override
  State<MultiStepSignUpPage> createState() => _MultiStepSignUpPageState();
}

class _MultiStepSignUpPageState extends State<MultiStepSignUpPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;

  // ✅ متغيرات الأخطاء لكل حقل
  String? _fullNameError;
  String? _phoneError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _genderError;
  String? _dobError;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://healix.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  // ====== Validation لكل خطوة ======
  bool _validateStep1() {
    bool valid = true;
    setState(() {
      _fullNameError = null;
      _phoneError = null;
    });

    if (_fullNameController.text.trim().isEmpty) {
      setState(() => _fullNameError = "Full name is required");
      valid = false;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = "Phone number is required");
      valid = false;
    }

    return valid;
  }

  bool _validateStep2() {
    bool valid = true;
    setState(() {
      _emailError = null;
      _usernameError = null;
    });

    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains("@")) {
      setState(() => _emailError = "Enter a valid email");
      valid = false;
    }

    if (_userNameController.text.trim().isEmpty) {
      setState(() => _usernameError = "Username is required");
      valid = false;
    }

    return valid;
  }

  bool _validateStep3() {
    bool valid = true;
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = "Password is required");
      valid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = "Please re-enter password");
      valid = false;
    }

    if (_passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "Passwords do not match");
      valid = false;
    }

    return valid;
  }

  bool _validateStep4() {
    bool valid = true;
    setState(() {
      _genderError = null;
      _dobError = null;
    });

    if (_selectedGender == null) {
      setState(() => _genderError = "Select your gender");
      valid = false;
    }

    if (_selectedDate == null) {
      setState(() => _dobError = "Select your birth date");
      valid = false;
    }

    return valid;
  }

  // ========= التنقل بين الصفحات =========
  void _nextPage() async {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;
    if (_currentStep == 2 && !_validateStep3()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (!_validateStep4()) return;
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

  // ====== رفع البيانات + تحويلها لكلاس UserInfo ======
  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final data = {
      "username": _userNameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "fullName": _fullNameController.text.trim(),
      "phoneNumber": _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      "dateOfBirth": _selectedDate?.toIso8601String(),
      "gender": _selectedGender,
    };

    try {
      final response = await _dio.post("/Auth/signup", data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ===== إنشاء كائن UserInfo =====
        UserInfo user = UserInfo(
          username: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          dateOfBirth: _selectedDate,
          gender: _selectedGender,
        );

        // ===== الانتقال إلى HomeScreen مع تمرير UserInfo =====
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      } else {
        _showDialog("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      String message = "Something went wrong";
      if (e.response != null && e.response?.data is Map) {
        message = e.response?.data["message"] ?? message;
      }
      _showDialog(message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Attention"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
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
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text(
              "Complete Sign Up",
              style: GoogleFonts.inriaSans(color: Colors.white),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSegmentedProgressBar(),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),
              Padding(
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
                      text: _currentStep == _totalSteps - 1
                          ? "Finish"
                          : "Next Step",
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Creating your account...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ====== Progress Bar ======
  Widget _buildSegmentedProgressBar() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        bool isActive = index <= _currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primarayColor
                  : AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }

  // ====== Steps مع Error Messages ======
  Widget _buildStep1() => _stepTemplate("First, What Can We Call You", [
    Text(
      "We'd Like To Get To Know You",
      style: GoogleFonts.inriaSans(
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    const Gap(30),
    HealixTextField(
      controller: _fullNameController,
      hint: "Full Name",
      errorText: _fullNameError,
    ),
    const Gap(16),
    HealixTextField(
      controller: _phoneController,
      hint: "Phone Number",
      errorText: _phoneError,
    ),
  ]);

  Widget _buildStep2() => _stepTemplate("Create Your Account Details", [
    const Gap(30),
    HealixTextField(
      controller: _emailController,
      hint: "Email Address",
      errorText: _emailError,
    ),
    const Gap(16),
    HealixTextField(
      controller: _userNameController,
      hint: "Username",
      errorText: _usernameError,
    ),
  ]);

  Widget _buildStep3() => _stepTemplate("Secure Your Account", [
    const Gap(30),
    HealixTextField(
      controller: _passwordController,
      hint: "Enter your password",
      isPassword: true,
      errorText: _passwordError,
    ),
    const Gap(16),
    HealixTextField(
      controller: _confirmPasswordController,
      hint: "Re-enter your password",
      isPassword: true,
      errorText: _confirmPasswordError,
    ),
  ]);

  Widget _buildStep4() => _stepTemplate("A Few More Details", [
    const Gap(30),
    Text(
      "Gender",
      style: GoogleFonts.inriaSans(
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    const Gap(4),
    if (_genderError != null)
      Text(
        _genderError!,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    const Gap(8),
    Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedGender = "Male");
            },
            child: _genderBox("Male"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedGender = "Female");
            },
            child: _genderBox("Female"),
          ),
        ),
      ],
    ),
    const Gap(16),
    Text(
      "Date of Birth",
      style: GoogleFonts.inriaSans(
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    if (_dobError != null)
      Text(_dobError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
    const Gap(8),
    _datePickerField(),
  ]);

  Widget _genderBox(String gender) {
    bool isSelected = _selectedGender == gender;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 55,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primarayColor.withOpacity(0.2)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primarayColor : Colors.grey.shade700,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          gender,
          style: GoogleFonts.inriaSans(
            color: isSelected ? AppColors.primarayColor : Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _datePickerField() {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        DateTime initial = _selectedDate ?? DateTime(2000, 1, 1);
        DateTime tempPicked = initial;

        await showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
            height: 320,
            color: Colors.black,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    color: Colors.grey[900],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedDate = tempPicked);
                            Navigator.pop(context);
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
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        backgroundColor: Colors.black,
                        maximumYear: DateTime.now().year,
                        minimumYear: 1900,
                        initialDateTime: initial,
                        onDateTimeChanged: (newDate) => tempPicked = newDate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.shade700, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          _selectedDate == null
              ? "Select your birth date"
              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
          style: GoogleFonts.inriaSans(
            color: _selectedDate == null
                ? Colors.grey.shade500
                : AppColors.primarayColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _stepTemplate(String title, List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inriaSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ...fields,
          ],
        ),
      ),
    );
  }
}
