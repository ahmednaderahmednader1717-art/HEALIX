import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:test_splash/widgets/common/healix_primary_button.dart';
import 'package:gap/gap.dart';

class MultiStepSignUpPage extends StatefulWidget {
  const MultiStepSignUpPage({super.key, this.user});
  final UserInfo? user;

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

  // Error messages
  String? _nameError;
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

  final Dio _dio = Dio(BaseOptions(baseUrl: "http://healix26.somee.com/api"));

  void _nextPage() async {
    // Clear previous errors
    setState(() {
      _nameError = null;
      _phoneError = null;
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _genderError = null;
      _dobError = null;
      _heightError = null;
      _weightError = null;
      _goalWeightError = null;
      _bodyTypeError = null;
      _dietTypeError = null;
    });

    // Validate current step
    if (_currentStep == 0) {
      bool isValid = true;
      if (_fullNameController.text.trim().isEmpty) {
        setState(() => _nameError = "Please enter your full name");
        isValid = false;
      }
      if (_phoneController.text.trim().isEmpty) {
        setState(() => _phoneError = "Please enter your phone number");
        isValid = false;
      }
      if (!isValid) return;
    }

    if (_currentStep == 1) {
      bool isValid = true;
      if (!_emailController.text.contains("@")) {
        setState(() => _emailError = "Please enter a valid email");
        isValid = false;
      }
      if (_userNameController.text.trim().isEmpty) {
        setState(() => _usernameError = "Please enter a username");
        isValid = false;
      }
      if (!isValid) return;
    }

    if (_currentStep == 2) {
      bool isValid = true;
      if (_passwordController.text.isEmpty) {
        setState(() => _passwordError = "Please enter a password");
        isValid = false;
      }
      if (_confirmPasswordController.text != _passwordController.text) {
        setState(() => _confirmPasswordError = "Passwords do not match");
        isValid = false;
      }
      if (!isValid) return;
    }

    if (_currentStep == 3) {
      bool isValid = true;
      if (_selectedGender == null) {
        setState(() => _genderError = "Please select your gender");
        isValid = false;
      }
      if (_selectedDate == null) {
        setState(() => _dobError = "Please select your date of birth");
        isValid = false;
      }
      if (_selectedHeight == null) {
        setState(() => _heightError = "Please select your height");
        isValid = false;
      }
      if (_selectedWeight == null) {
        setState(() => _weightError = "Please select your weight");
        isValid = false;
      }
      if (_selectedGoalWeight == null) {
        setState(() => _goalWeightError = "Please select your goal weight");
        isValid = false;
      }
      if (!isValid) return;
    }

    if (_currentStep == 4) {
      if (_selectedBodyType == null) {
        setState(() => _bodyTypeError = "Please select your body type");
        return;
      }
    }

    if (_currentStep == 5) {
      if (_selectedDietType == null) {
        setState(() => _dietTypeError = "Please select your diet type");
        return;
      }
    }

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
    String? accessToken;

    try {
      // ✅ PHASE 1: إنشاء الحساب بالبيانات الأساسية فقط (مثل Google Sign-Up)
      // Backend لا يدعم كل الحقول في endpoint التسجيل
      final basicSignupData = {
        "username": _userNameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "fullName": _fullNameController.text.trim(),
        "profilePictureUrl": null, // سيتم رفعها لاحقاً
      };

      print("🚀 === PHASE 1: CREATING ACCOUNT ===");
      print("📤 Sending basic signup request to: /Auth/signup");
      print("📝 Basic signup data:");
      basicSignupData.forEach((key, value) {
        print("   $key: $value (${value.runtimeType})");
      });

      final signupResp = await _dio.post(
        "/Auth/signup",
        data: basicSignupData,
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      print("📥 Signup Response Status: ${signupResp.statusCode}");
      print("📥 Signup Response Data: ${signupResp.data}");

      // ✅ التحقق من النتيجة
      if (signupResp.statusCode == 200 || signupResp.statusCode == 201) {
        print("✅ Account created successfully!");

        // 👇 استخراج التوكن من رد التسجيل
        String? refreshToken;
        if (signupResp.data is Map) {
          // Try both 'token' and 'accessToken' keys
          accessToken =
              signupResp.data['token'] ?? signupResp.data['accessToken'];
          refreshToken = signupResp.data['refreshToken'] ?? "";
        }

        // 👇 حفظ التوكن في SharedPreferences
        if (accessToken != null && accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", accessToken);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await prefs.setString("refreshToken", refreshToken);
          }
          print("✅ Token saved successfully");
        } else {
          print("⚠️ No token received from server");
        }

        // ✅ PHASE 2: تحديث بيانات البروفايل الإضافية (phone, dateOfBirth, gender)
        if (accessToken != null && accessToken.isNotEmpty) {
          print("🚀 === PHASE 2: UPDATING PROFILE DATA ===");
          try {
            final profileUpdateData = {
              if (_phoneController.text.trim().isNotEmpty)
                "phoneNumber": _phoneController.text.trim(),
              if (_selectedDate != null)
                "dateOfBirth": _selectedDate!.toIso8601String(),
              if (_selectedGender != null) "gender": _selectedGender,
            };

            if (profileUpdateData.isNotEmpty) {
              print(
                "📤 Updating profile with: ${profileUpdateData.keys.toList()}",
              );
              final profileResp = await _dio.put(
                "/User/update-profile",
                data: profileUpdateData,
                options: Options(
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $accessToken",
                  },
                  validateStatus: (status) => status != null && status < 600,
                ),
              );

              if (profileResp.statusCode == 200) {
                print("✅ Profile data updated successfully");
              } else {
                print("⚠️ Profile update failed: ${profileResp.statusCode}");
              }
            }
          } catch (e) {
            print("⚠️ Profile update error (non-critical): $e");
            // Don't block signup if profile update fails
          }

          // ✅ PHASE 3: تحديث البيانات الصحية (height, weight, goalWeight, bodyType, dietType)
          print("🚀 === PHASE 3: UPDATING HEALTH PROFILE ===");
          try {
            final healthUpdateData = {
              if (_selectedHeight != null) "height": _selectedHeight,
              if (_selectedWeight != null) "weight": _selectedWeight,
              if (_selectedGoalWeight != null)
                "goalWeight": _selectedGoalWeight,
              if (_selectedBodyType != null) "bodyType": _selectedBodyType,
              if (_selectedDietType != null) "dietType": _selectedDietType,
            };

            if (healthUpdateData.isNotEmpty) {
              print(
                "📤 Updating health profile with: ${healthUpdateData.keys.toList()}",
              );
              final healthResp = await _dio.put(
                "/User/update-health-profile",
                data: healthUpdateData,
                options: Options(
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $accessToken",
                  },
                  validateStatus: (status) => status != null && status < 600,
                ),
              );

              if (healthResp.statusCode == 200) {
                print("✅ Health profile updated successfully");
              } else {
                print(
                  "⚠️ Health profile update failed: ${healthResp.statusCode}",
                );
              }
            }
          } catch (e) {
            print("⚠️ Health profile update error (non-critical): $e");
            // Don't block signup if health update fails
          }
        }

        // ✅ PHASE 4: رفع الصورة (اختياري) - لا توقف التسجيل إذا فشل
        if (_profileImage != null && accessToken != null) {
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

            print("📤 Attempting to upload profile picture...");

            // 👇 إضافة التوكن في الهيدر
            final resp = await _dio.post(
              "/User/upload-profile-picture",
              data: fd,
              options: Options(
                headers: {'Authorization': 'Bearer $accessToken'},
                // Don't throw on status code errors - handle them gracefully
                validateStatus: (status) => status != null && status < 600,
              ),
            );

            // 🐛 طباعة الاستجابة الكاملة للتشخيص
            print("📦 Upload Response Status: ${resp.statusCode}");
            print("📦 Upload Response Data Type: ${resp.data.runtimeType}");
            print("📦 Upload Response Data: ${resp.data}");

            // Check if upload was successful
            if (resp.statusCode == 200 || resp.statusCode == 201) {
              uploadedProfileUrl = _extractUrlFromResponse(resp.data);
              if (uploadedProfileUrl != null && uploadedProfileUrl.isNotEmpty) {
                setState(() => _uploadedProfileUrl = uploadedProfileUrl);
                print("✅ Uploaded: $_uploadedProfileUrl");

                // ✅ تحديث البروفايل بالصورة الجديدة
                try {
                  await _dio.put(
                    '/User/update-profile-picture',
                    data: {'profilePictureUrl': uploadedProfileUrl},
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer $accessToken',
                        'Content-Type': 'application/json',
                      },
                    ),
                  );
                  print("✅ Profile picture updated in account");
                } catch (updateError) {
                  print(
                    "⚠️ Failed to update profile picture in account: $updateError",
                  );
                }
              }
            } else {
              // Upload failed but don't block signup
              print(
                "⚠️ Profile picture upload failed with status ${resp.statusCode}",
              );
              print("⚠️ Error details: ${resp.data}");
              print("ℹ️ Continuing with signup - user can upload photo later");
            }
          } catch (e) {
            // Catch any upload errors but don't block signup
            print("⚠️ Profile picture upload error: $e");
            print("ℹ️ Continuing with signup - user can upload photo later");
          }
        }

        // 3. المتابعة للصفحة الرئيسية
        Navigator.pushAndRemoveUntil(
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
          (route) => false,
        );
      } else {
        // ❌ Signup failed - show the actual server error
        print("❌ Signup failed with status code: ${signupResp.statusCode}");
        final respData = signupResp.data;

        String errorMessage = "Signup failed";

        if (respData is Map) {
          // Try to extract error message from response
          errorMessage =
              respData['message'] ??
              respData['error'] ??
              respData['title'] ??
              "Signup failed with status ${signupResp.statusCode}";

          // If there are validation errors, show them
          if (respData['errors'] != null) {
            errorMessage += "\n\nDetails:";
            final errors = respData['errors'];
            if (errors is Map) {
              errors.forEach((key, value) {
                errorMessage +=
                    "\n• $key: ${value is List ? value.join(', ') : value}";
              });
            }
          }
        } else {
          errorMessage =
              "Server error: ${signupResp.statusCode}\n${respData?.toString() ?? 'Unknown error'}";
        }

        print("❌ Error message to show: $errorMessage");
        _showDialog(errorMessage);
      }
    } on DioException catch (e) {
      print("❌ === DIO EXCEPTION OCCURRED ===");
      print("❌ Error type: ${e.type}");
      print("❌ Error message: ${e.message}");
      print("❌ Response status: ${e.response?.statusCode}");
      print("❌ Response data: ${e.response?.data}");

      String msg = "Network error";
      if (e.response?.data is Map && e.response?.data["message"] != null) {
        msg = e.response?.data["message"];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        msg = "Connection timeout - please check your internet";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        msg = "Server took too long to respond";
      } else if (e.type == DioExceptionType.connectionError) {
        msg = "Cannot connect to server - check your internet";
      } else {
        msg = e.message ?? "Something went wrong";
      }
      _showDialog(msg);
    } catch (e) {
      print("❌ === UNEXPECTED ERROR ===");
      print("❌ Error: $e");
      _showDialog("Unexpected error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _extractUrlFromResponse(dynamic responseBody) {
    try {
      print(
        "🔍 Extracting URL from response type: ${responseBody.runtimeType}",
      );

      // Case 1: Response is a Map (JSON object)
      if (responseBody is Map<String, dynamic>) {
        // Try common field names
        final url =
            responseBody['url'] ??
            responseBody['profilePictureUrl'] ??
            responseBody['imageUrl'] ??
            responseBody['fileUrl'] ??
            responseBody['path'];

        if (url != null) {
          print("✅ Found URL in map: $url");
          return url.toString();
        }

        // Print all keys to help debug
        print("⚠️ Available keys in response: ${responseBody.keys.toList()}");
      }

      // Case 2: Response is a String
      if (responseBody is String) {
        // Try to parse as JSON first
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            final url =
                decoded['url'] ??
                decoded['profilePictureUrl'] ??
                decoded['imageUrl'] ??
                decoded['fileUrl'];
            if (url != null) {
              print("✅ Found URL in decoded JSON: $url");
              return url.toString();
            }
          }
        } catch (jsonError) {
          // Not valid JSON, might be plain URL
          if (responseBody.startsWith('http://') ||
              responseBody.startsWith('https://')) {
            print("✅ Response is direct URL: $responseBody");
            return responseBody;
          }
        }
      }

      print("⚠️ Could not extract URL from response");
    } catch (e) {
      print('⚠️ Error extracting URL: $e');
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
          backgroundColor: Colors.black,
          title: Text(
            "Complete Sign Up",
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
        nameError: _nameError,
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
        selectedHeight: _selectedHeight?.toInt(), // للـPicker يجب int
        heightError: _heightError,
        selectedWeight: _selectedWeight?.toInt(),
        weightError: _weightError,
        selectedGoalWeight: _selectedGoalWeight?.toInt(),
        goalWeightError: _goalWeightError,
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
          width: 60 * scale,
          height: 60 * scale,
          borderRadius: 999,
          backgroundColor: AppColors.primarayColor.withOpacity(0.4),
        ),
        Gap(20 * scale),
        HealixPrimaryButton(
          height: 60 * scale,
          width: 300 * scale,
          text: _currentStep == _totalSteps - 1 ? "Finish" : "Next Step",

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
