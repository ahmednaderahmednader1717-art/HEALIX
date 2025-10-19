import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/auth/log_in_screen.dart';
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

  // ✅ تحقق من توافر username و email
  Future<bool> _checkUsernameEmailAvailability() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://healix.somee.com/api",
        headers: {"Content-Type": "application/json"},
      ),
    );

    try {
      final response = await dio.post(
        "/Auth/signup",
        data: {
          "username": _userNameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": "Temp@1234",
          "fullName": "Temp User",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey("message")) {
          final msg = data["message"].toString().toLowerCase();

          if (msg.contains("username") && msg.contains("exists")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Username already exists")),
            );
            return false;
          } else if (msg.contains("email") && msg.contains("exists")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Email already exists")),
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  // ✅ الانتقال للخطوة التالية مع التحقق من المدخلات
  void _nextPage() async {
    // الخطوة 1
    if (_currentStep == 0) {
      if (_fullNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your full name")),
        );
        return;
      }
    }

    // الخطوة 2
    if (_currentStep == 1) {
      if (_emailController.text.trim().isEmpty ||
          _userNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
        return;
      }

      bool available = await _checkUsernameEmailAvailability();
      if (!available) return;
    }

    // الخطوة 3
    if (_currentStep == 2) {
      if (_passwordController.text.trim().isEmpty ||
          _confirmPasswordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter and confirm your password"),
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
        return;
      }
    }

    // الخطوة 4
    if (_currentStep == 3) {
      if (_selectedGender == null || _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all required fields")),
        );
        return;
      }
    }

    // الانتقال للخطوة التالية فقط لو كله تمام
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  // ✅ تنفيذ التسجيل الفعلي
  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final dio = Dio(
      BaseOptions(
        baseUrl: "http://healix.somee.com/api",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

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
      final response = await dio.post("/Auth/signup", data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected response: ${response.statusCode}"),
          ),
        );
      }
    } on DioException catch (e) {
      String message = "Something went wrong";

      if (e.response != null) {
        message =
            e.response?.data["message"] ??
            e.response?.data.toString() ??
            "Server error";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
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
                      onPressed: _currentStep == _totalSteps - 1
                          ? _signUp
                          : _nextPage,
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

  // Progress Bar
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

  // Step 1
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
    HealixTextField(controller: _fullNameController, hint: "Full Name"),
    const Gap(16),
    HealixTextField(
      controller: _phoneController,
      hint: "Phone Number (optional)",
    ),
  ]);

  // Step 2
  Widget _buildStep2() => _stepTemplate("Create Your Account Details", [
    const Gap(30),
    HealixTextField(controller: _emailController, hint: "Email Address"),
    const Gap(16),
    HealixTextField(controller: _userNameController, hint: "Username"),
  ]);

  // Step 3
  Widget _buildStep3() => _stepTemplate("Secure Your Account", [
    const Gap(30),
    HealixTextField(
      controller: _passwordController,
      hint: "Enter your password",
      isPassword: true,
    ),
    const Gap(16),
    HealixTextField(
      controller: _confirmPasswordController,
      hint: "Re-enter your password",
      isPassword: true,
    ),
  ]);

  // Step 4
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
    const Gap(12),
    Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = "Male"),
            child: _genderBox("Male"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = "Female"),
            child: _genderBox("Female"),
          ),
        ),
      ],
    ),
    const SizedBox(height: 30),
    Text(
      "Date of Birth",
      style: GoogleFonts.inriaSans(
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    const Gap(10),
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
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: const TextStyle(
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
                        onDateTimeChanged: (DateTime newDate) {
                          tempPicked = newDate;
                        },
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
