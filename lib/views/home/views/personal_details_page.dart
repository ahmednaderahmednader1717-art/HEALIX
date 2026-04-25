import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PersonalDetailsPage extends StatefulWidget {
  final UserInfo user;
  const PersonalDetailsPage({super.key, required this.user});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  late UserInfo user;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  void _showTopMessage(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
              left: 40,
              right: 40,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> getUserInfoAgain() async {
    try {
      final token = await getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("غير مسجل الدخول. الرجاء إعادة التسجيل")),
        );
        return;
      }
      final response = await dio.get(
        "http://healix26.somee.com/api/Auth/verify-token", // عدل Endpoint بحسب الـAPI عندك
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      if (response.statusCode == 200) {
        if (response.data != null && response.data['user'] != null) {
          setState(() {
            user = UserInfo.fromJson(response.data['user']);
          });
        }
      }
    } catch (e) {
      print("Error getting user info: $e");
    }
  }

  Future<void> updateHealthProfile({
    double? height,
    double? weight,
    String? bodyType,
    String? dietType,
    double? goalWeight,
  }) async {
    final token = await getToken();
    print("🔍 Token retrieved: ${token != null ? 'EXISTS' : 'NULL'}");
    if (token != null) {
      print(
        "📝 Token value (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
      );
      print("📏 Token length: ${token.length}");
    }

    if (token == null || token.isEmpty) {
      print("❌ Token is null or empty, showing error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("غير مسجل الدخول. الرجاء إعادة تسجيل الدخول"),
          action: SnackBarAction(
            label: "تسجيل الدخول",
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
      return;
    }

    // ✅ تحديث فوري للـ UI قبل ما نبعت للـ API (Optimistic Update)
    setState(() {
      if (height != null) user.userHeight = height;
      if (weight != null) user.userWeight = weight;
      if (bodyType != null) user.bodyType = bodyType;
      if (dietType != null) user.dietType = dietType;
      if (goalWeight != null) user.userGoalWeight = goalWeight;
    });

    final payload = {
      "height": user.userHeight,
      "weight": user.userWeight,
      "bodyType": user.bodyType,
      "dietType": user.dietType,
      "goalWeight": user.userGoalWeight,
    };

    print("📤 Sending update request with token...");
    print("🎯 Payload: $payload");

    try {
      final response = await dio.put(
        "http://healix26.somee.com/api/User/update-health-profile",
        data: payload,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        // ✅ تحديث من الـ API response للتأكد من المزامنة
        if (data != null && data['user'] != null) {
          setState(() {
            user = UserInfo.fromJson(data['user']);
          });
        }

        // ✅ رسالة نجاح في الأعلى باستخدام Overlay
        _showTopMessage(context, "تم تحديث البيانات بنجاح");
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("انتهت صلاحية التوكن. الرجاء إعادة تسجيل الدخول"),
            action: SnackBarAction(
              label: "تسجيل الدخول",
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء التحديث: ${response.statusCode}"),
          ),
        );
      }
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.statusCode} - ${e.message}");

      if (e.response?.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("انتهت صلاحية الجلسة. يرجى إعادة تسجيل الدخول"),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: "تسجيل الدخول",
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حصل خطأ أثناء الإرسال: ${e.message}")),
        );
      }
    } catch (e) {
      print("❌ Error updating health profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حصل خطأ غير متوقع: $e")));
    }
  }

  Future<double?> showNumberEditDialog(
    String title,
    double? currentValue, {
    int min = 30,
    int max = 250,
  }) async {
    int tempValue = currentValue?.toInt() ?? min;
    int? selectedValue;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 320,
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text(
                      "Done",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    onPressed: () {
                      selectedValue = tempValue;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                backgroundColor: theme.scaffoldBackgroundColor,
                scrollController: FixedExtentScrollController(
                  initialItem: (currentValue?.toInt() ?? min) - min,
                ),
                onSelectedItemChanged: (i) => tempValue = min + i,
                children: List.generate(
                  max - min + 1,
                  (i) => Center(
                    child: Text(
                      "${min + i}",
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return selectedValue?.toDouble();
  }

  Future<DateTime?> showDateOfBirthDialog(DateTime? currentValue) async {
    DateTime tempDate = currentValue ?? DateTime(2000, 1, 1);
    DateTime? selectedDate;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 320,
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text(
                      "Done",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    onPressed: () {
                      selectedDate = tempDate;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.dmy,
                  initialDateTime: currentValue ?? DateTime(2000, 1, 1),
                  minimumYear: 1900,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return selectedDate;
  }

  Future<void> updateProfile({DateTime? dateOfBirth, String? gender}) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("غير مسجل الدخول. الرجاء إعادة تسجيل الدخول")),
      );
      return;
    }

    // Update UI optimistically
    setState(() {
      if (dateOfBirth != null) user.dateOfBirth = dateOfBirth;
      if (gender != null) user.gender = gender;
    });

    final payload = {
      if (dateOfBirth != null) "dateOfBirth": dateOfBirth.toIso8601String(),
      if (gender != null) "gender": gender,
    };

    try {
      final response = await dio.put(
        "http://healix26.somee.com/api/User/update-profile",
        data: payload,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['user'] != null) {
          setState(() {
            user = UserInfo.fromJson(data['user']);
          });
        }
        _showTopMessage(context, "تم تحديث البيانات بنجاح");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء التحديث: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حصل خطأ أثناء التحديث: $e")));
    }
  }

  Future<String?> showTextEditDialog(String title, String? currentValue) async {
    final colorScheme = Theme.of(context).colorScheme;
    // للـ Gender
    if (title.toLowerCase().contains('gender')) {
      return await showGenderDialog(currentValue);
    }
    // للـ Body Type
    if (title.toLowerCase().contains('body')) {
      return await showBodyTypeDialog(currentValue);
    }
    // للـ Diet Type
    if (title.toLowerCase().contains('diet')) {
      return await showDietTypeDialog(currentValue);
    }

    // Default text input for other cases
    TextEditingController controller = TextEditingController(
      text: currentValue ?? "",
    );
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Edit $title', style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Enter new $title",
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              'Save',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> showGenderDialog(String? currentValue) async {
    final genders = ['Male', 'Female'];
    String? selected;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 280,
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                color: colorScheme.surfaceContainerHighest,
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
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: genders.map((gender) {
                    final isSelected = gender == currentValue;
                    return ListTile(
                      title: Text(
                        gender,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        selected = gender;
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return selected;
  }

  Future<String?> showBodyTypeDialog(String? currentValue) async {
    final bodyTypes = ['Ectomorph', 'Mesomorph', 'Endomorph'];
    String? selected;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 300,
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                color: colorScheme.surfaceContainerHighest,
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
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: bodyTypes.map((type) {
                    final isSelected = type == currentValue;
                    return ListTile(
                      title: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        selected = type;
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return selected;
  }

  Future<String?> showDietTypeDialog(String? currentValue) async {
    final dietTypes = ['Standard', 'Vegetarian', 'Vegan', 'Pescatarian'];
    String? selected;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 400,
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                color: colorScheme.surfaceContainerHighest,
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
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: dietTypes.map((diet) {
                    final isSelected = diet == currentValue;
                    return ListTile(
                      title: Text(
                        diet,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        selected = diet;
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final w = screenWidth / 430.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final goalWeight = '${user.userGoalWeight ?? "--"}KG';
    final currentWeight = '${user.userWeight ?? "--"}KG';
    final height = '${user.userHeight ?? "--"}CM';
    final birthDate = user.dateOfBirth != null
        ? DateFormat('dd-MM-yyyy').format(user.dateOfBirth!)
        : "--";
    final gender = user.gender ?? "--";
    final bodyType = user.bodyType ?? "--";
    final dietType = user.dietType ?? "--";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Personal Details",
          style: GoogleFonts.outfit(
            color: colorScheme.onSurface,
            fontSize: 22 * w,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 16 * w),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40 * w,
                height: 40 * w,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: colorScheme.onSurface,
                  size: 20 * w,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24 * w, vertical: 10 * w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20 * w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20 * w),
              ),
              margin: EdgeInsets.only(bottom: 16 * w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal Weight',
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14 * w,
                          ),
                        ),
                        SizedBox(height: 5 * w),
                        Text(
                          goalWeight,
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurface,
                            fontSize: 22 * w,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.surface,
                      backgroundColor: colorScheme.onSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      double? newGoal = await showNumberEditDialog(
                        "Goal Weight",
                        user.userGoalWeight,
                        min: 30,
                        max: 200,
                      );
                      if (newGoal != null) {
                        await updateHealthProfile(goalWeight: newGoal);
                      }
                    },
                    child: Text(
                      'Change Goal',
                      style: GoogleFonts.outfit(
                        color: colorScheme.surface,
                        fontSize: 15 * w,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20 * w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20 * w),
              ),
              child: Column(
                children: [
                  _infoRow(
                    'Current weight',
                    currentWeight,
                    onEdit: () async {
                      double? newWeight = await showNumberEditDialog(
                        "Weight",
                        user.userWeight,
                        min: 30,
                        max: 200,
                      );
                      if (newWeight != null) {
                        await updateHealthProfile(weight: newWeight);
                      }
                    },
                    context: context,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow(
                    'Height',
                    height,
                    onEdit: () async {
                      double? newHeight = await showNumberEditDialog(
                        "Height",
                        user.userHeight,
                        min: 120,
                        max: 220,
                      );
                      if (newHeight != null) {
                        await updateHealthProfile(height: newHeight);
                      }
                    },
                    context: context,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow(
                    'Date of birth',
                    birthDate,
                    onEdit: () async {
                      DateTime? newDate = await showDateOfBirthDialog(
                        user.dateOfBirth,
                      );
                      if (newDate != null) {
                        await updateProfile(dateOfBirth: newDate);
                      }
                    },
                    context: context,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow(
                    'Gender',
                    gender,
                    onEdit: () async {
                      String? newGender = await showTextEditDialog(
                        "Gender",
                        user.gender,
                      );
                      if (newGender != null && newGender.isNotEmpty) {
                        await updateProfile(gender: newGender);
                      }
                    },
                    context: context,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow(
                    'Body Type',
                    bodyType,
                    onEdit: () async {
                      String? newBodyType = await showTextEditDialog(
                        "Body Type",
                        user.bodyType,
                      );
                      if (newBodyType != null && newBodyType.isNotEmpty) {
                        await updateHealthProfile(bodyType: newBodyType);
                      }
                    },
                    context: context,
                  ),
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow(
                    'Diet Type',
                    dietType,
                    onEdit: () async {
                      String? newDietType = await showTextEditDialog(
                        "Diet Type",
                        user.dietType,
                      );
                      if (newDietType != null && newDietType.isNotEmpty) {
                        await updateHealthProfile(dietType: newDietType);
                      }
                    },
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {required VoidCallback onEdit, required BuildContext context}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final w = screenWidth / 430.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14 * w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15 * w,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: colorScheme.onSurface,
              fontSize: 16 * w,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 12 * w),
          InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.all(4 * w),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20 * w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
