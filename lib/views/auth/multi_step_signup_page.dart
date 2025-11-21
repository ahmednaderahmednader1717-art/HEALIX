import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
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
  final int _totalSteps = 7;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  double? _selectedHeight; // was int? -- now double?
  double? _selectedWeight; // was int? -- now double?
  double? _selectedGoalWeight; // was int? -- now double?
  String? _selectedBodyType;
  String? _selectedDietType;
  dynamic _profileImage; // File (mobile) أو Uint8List (web)
  String? _uploadedProfileUrl;
  bool _isLoading = false;

  final Dio _dio = Dio(BaseOptions(baseUrl: "http://healix.somee.com/api"));

  bool _validateStep1() =>
      _fullNameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;
  bool _validateStep2() =>
      _emailController.text.contains("@") &&
      _userNameController.text.trim().isNotEmpty;
  bool _validateStep3() =>
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text == _passwordController.text;
  bool _validateStep4() =>
      _selectedGender != null &&
      _selectedDate != null &&
      _selectedHeight != null &&
      _selectedWeight != null &&
      _selectedGoalWeight != null;
  bool _validateStepBodyType() => _selectedBodyType != null;
  bool _validateStepDietType() => _selectedDietType != null;

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
      await _signUpWithProfileImage();
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

  Future<void> _signUpWithProfileImage() async {
    setState(() => _isLoading = true);
    String? uploadedProfileUrl;
    try {
      // إعداد البيانات الأساسية (أرسل القيم الرقمية كـdouble)
      final signupData = {
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
        "profilePictureUrl": null,
      };

      final signupResp = await _dio.post("/Auth/signup", data: signupData);

      // ✅ التحقق من النتيجة
      if (signupResp.statusCode == 200 || signupResp.statusCode == 201) {
        // 👇 استخراج التوكن من رد التسجيل
        String? accessToken;
        if (signupResp.data is Map && signupResp.data['accessToken'] != null) {
          accessToken = signupResp.data['accessToken'];
        }

        // 2. رفع الصورة (اختياري)
        if (_profileImage != null) {
          try {
            FormData fd;
            if (_profileImage is File) {
              fd = FormData.fromMap({
                "file": await MultipartFile.fromFile(
                  (_profileImage as File).path,
                ),
              });
            } else if (_profileImage is Uint8List) {
              fd = FormData.fromMap({
                "file": MultipartFile.fromBytes(
                  (_profileImage as Uint8List),
                  filename: "profile.jpg",
                ),
              });
            } else {
              throw Exception("الصورة غير مدعومة");
            }

            // 👇 إضافة التوكن في الهيدر
            final resp = await _dio.post(
              "/User/upload-profile-picture",
              data: fd,
              options: Options(
                headers: {
                  if (accessToken != null)
                    'Authorization': 'Bearer $accessToken',
                },
              ),
            );

            uploadedProfileUrl = _extractUrlFromResponse(resp.data);
            if (uploadedProfileUrl != null && uploadedProfileUrl.isNotEmpty) {
              setState(() => _uploadedProfileUrl = uploadedProfileUrl);
              print("✅ Uploaded: $_uploadedProfileUrl");
            }
          } catch (e) {
            print("⚠️ Upload error: $e");
          }
        }

        // 3. المتابعة للصفحة الرئيسية
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
                bodyType: _selectedBodyType,
                userHeight: _selectedHeight,
                userWeight: _selectedWeight,
                userGoalWeight: _selectedGoalWeight,
                profilePictureUrl: uploadedProfileUrl,
              ),
            ),
          ),
        );
      } else {
        // ✅ عرض الرسالة الفعلية من السيرفر (مثل Username already exists)
        final respData = signupResp.data;
        if (respData is Map && respData['message'] != null) {
          _showDialog(respData['message']);
        } else {
          _showDialog(
            "Unexpected error: ${signupResp.statusCode}\n${signupResp.data}",
          );
        }
      }
    } on DioException catch (e) {
      String msg = "";
      if (e.response?.data is Map && e.response?.data["message"] != null) {
        msg = e.response?.data["message"];
      } else {
        msg = e.message ?? "Something went wrong";
      }
      _showDialog(msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _extractUrlFromResponse(dynamic responseBody) {
    try {
      if (responseBody is Map<String, dynamic>) {
        return responseBody['url'] ?? responseBody['profilePictureUrl'];
      }
      if (responseBody is String) {
        final decoded = jsonDecode(responseBody);
        return decoded['url'] ?? decoded['profilePictureUrl'];
      }
    } catch (e) {
      print('⚠️ تحليل الرد فشل: $e');
    }
    return null;
  }

  void _showDialog(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = min(
      MediaQuery.of(context).size.width / 430,
      MediaQuery.of(context).size.height / 932,
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "Complete Sign Up",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildProgressBar(),
                Expanded(child: _buildPages()),
                _buildNavigationButtons(scale),
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

  Widget _buildPages() => PageView(
    controller: _pageController,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      StepPersonalInfo(
        nameController: _fullNameController,
        phoneController: _phoneController,
        nameError: null,
        phoneError: null,
      ),
      StepAccountInfo(
        emailController: _emailController,
        usernameController: _userNameController,
        emailError: null,
        usernameError: null,
      ),
      StepPassword(
        passwordController: _passwordController,
        confirmController: _confirmPasswordController,
        passwordError: null,
        confirmError: null,
      ),
      StepExtraDetails(
        selectedGender: _selectedGender,
        genderError: null,
        selectedDate: _selectedDate,
        dobError: null,
        selectedHeight: _selectedHeight?.toInt(), // للـPicker يجب int
        heightError: null,
        selectedWeight: _selectedWeight?.toInt(),
        weightError: null,
        selectedGoalWeight: _selectedGoalWeight?.toInt(),
        goalWeightError: null,
        onSelectGender: (g) => setState(() => _selectedGender = g),
        onSelectDate: (ctx) async => await _pickDate(ctx),
        onSelectHeight: (ctx) async => await _pickIntValue(
          ctx,
          "Height",
          120,
          220,
          _selectedHeight?.toInt(),
          (v) => setState(() => _selectedHeight = v.toDouble()),
        ),
        onSelectWeight: (ctx) async => await _pickIntValue(
          ctx,
          "Weight",
          30,
          200,
          _selectedWeight?.toInt(),
          (v) => setState(() => _selectedWeight = v.toDouble()),
        ),
        onSelectGoalWeight: (ctx) async => await _pickIntValue(
          ctx,
          "Goal weight",
          30,
          200,
          _selectedGoalWeight?.toInt(),
          (v) => setState(() => _selectedGoalWeight = v.toDouble()),
        ),
      ),
      StepBodyType(
        selectedBodyType: _selectedBodyType,
        errorText: null,
        onSelect: (bt) => setState(() => _selectedBodyType = bt),
      ),
      StepDietType(
        selectedDietType: _selectedDietType,
        errorText: null,
        onSelect: (dt) => setState(() => _selectedDietType = dt),
      ),
      StepProfilePhoto(
        selectedImage: _profileImage,
        onImageSelected: (fileOrBytes) =>
            setState(() => _profileImage = fileOrBytes),
      ),
    ],
  );

  Widget _buildProgressBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    child: Row(
      children: List.generate(_totalSteps, (index) {
        bool isActive = index <= _currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarayColor : Colors.grey[700],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    ),
  );

  Widget _buildNavigationButtons(double scale) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HealixPrimaryButton.iconOnly(
                      leading: Icon(
                        _currentStep > 0 ? Icons.arrow_back : Icons.close,
                        color: Colors.white,
                        size: 30 * scale,
                      ),
                      onPressed: _currentStep > 0
                          ? _previousPage
                          : () => Navigator.pop(context),
                      width: 60 *scale,
                      height: 60 *scale,
                      borderRadius: 999,
                      backgroundColor: AppColors.primarayColor.withOpacity(0.4),
                    ),
                    Gap(20 *scale),
                    HealixPrimaryButton(
                      height: 60*scale,
                      width: 300 *scale,
                      text: _currentStep == _totalSteps - 1
                          ? "Finish"
                          : "Next Step",
                          
                      onPressed: _nextPage,
                    ),
      ],
    ),
  );

  Future<void> _pickDate(BuildContext context) async {
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
                        style: TextStyle(color: Colors.white70),
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
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    backgroundColor: Colors.black,
                    initialDateTime: initial,
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (newDate) => tempPicked = newDate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickIntValue(
    BuildContext context,
    String label,
    int min,
    int max,
    int? value,
    Function(int) onSelected,
  ) async {
    int tempValue = value ?? min;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => _buildCupertinoPickerContainer(
        onDone: () => onSelected(tempValue),
        child: CupertinoPicker(
          itemExtent: 40,
          backgroundColor: Colors.black,
          scrollController: FixedExtentScrollController(
            initialItem: (value ?? min) - min,
          ),
          onSelectedItemChanged: (i) => tempValue = min + i,
          children: List.generate(
            max - min + 1,
            (i) => Center(
              child: Text(
                "${min + i}",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoPickerContainer({
    required Widget child,
    required VoidCallback onDone,
  }) => Container(
    height: 320,
    color: Colors.black,
    child: Column(
      children: [
        Container(
          color: Colors.grey[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: Text(
                  "Done",
                  style: TextStyle(color: AppColors.primarayColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onDone();
                },
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}
