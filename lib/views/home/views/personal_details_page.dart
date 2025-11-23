import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 300),
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E).withOpacity(0.88),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
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
            begin: Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    Future.delayed(Duration(milliseconds: 2000), () {
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
          SnackBar(content: Text("غير مسجل الدخول. الرجاء إعادة التسجيل")),
        );
        return;
      }
      final response = await dio.get(
        "http://healix.somee.com/api/Auth/verify-token", // عدل Endpoint بحسب الـAPI عندك
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
    String? gender,
  }) async {
    final token = await getToken();
    print("🔍 Token retrieved: ${token != null ? 'EXISTS' : 'NULL'}");
    if (token != null) {
      print("📝 Token value (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...");
      print("📏 Token length: ${token.length}");
    }
    
    if (token == null || token.isEmpty) {
      print("❌ Token is null or empty, showing error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("غير مسجل الدخول. الرجاء إعادة تسجيل الدخول"),
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
      if (gender != null) user.gender = gender;
    });

    final payload = {
      "height": user.userHeight,
      "weight": user.userWeight,
      "bodyType": user.bodyType,
      "dietType": user.dietType,
      "goalWeight": user.userGoalWeight,
      "gender": user.gender,
    };
    
    print("📤 Sending update request with token...");
    print("🎯 Payload: $payload");
    
    try {
      final response = await dio.put(
        "http://healix.somee.com/api/Auth/update-health-profile",
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
            content: Text("انتهت صلاحية التوكن. الرجاء إعادة تسجيل الدخول"),
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
            content: Text("انتهت صلاحية الجلسة. يرجى إعادة تسجيل الدخول"),
            duration: Duration(seconds: 4),
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

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
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
                backgroundColor: Colors.black,
                scrollController: FixedExtentScrollController(
                  initialItem: (currentValue?.toInt() ?? min) - min,
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
          ],
        ),
      ),
    );

    return selectedValue?.toDouble();
  }

  Future<String?> showTextEditDialog(String title, String? currentValue) async {
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
        backgroundColor: AppColors.ContainerColor,
        title: Text('Edit $title', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $title",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Save', style: TextStyle(color: AppColors.primarayColor)),
          ),
        ],
      ),
    );
  }

  Future<String?> showGenderDialog(String? currentValue) async {
    final genders = ['Male', 'Female'];
    String? selected;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 280,
          color: Colors.black,
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
                      child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Done", style: TextStyle(color: AppColors.primarayColor)),
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
                          color: isSelected ? AppColors.primarayColor : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: AppColors.primarayColor)
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

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 300,
          color: Colors.black,
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
                      child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Done", style: TextStyle(color: AppColors.primarayColor)),
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
                          color: isSelected ? AppColors.primarayColor : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: AppColors.primarayColor)
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

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: 400,
          color: Colors.black,
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
                      child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Done", style: TextStyle(color: AppColors.primarayColor)),
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
                          color: isSelected ? AppColors.primarayColor : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: AppColors.primarayColor)
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
    final goalWeight = '${user.userGoalWeight ?? "--"}KG';
    final currentWeight = '${user.userWeight ?? "--"}KG';
    final height = '${user.userHeight ?? "--"}CM';
    final birthDate = user.dateOfBirth != null
        ? user.dateOfBirth.toString().substring(0, 10)
        : "--";
    final gender = '${user.gender ?? "--"}';
    final bodyType = '${user.bodyType ?? "--"}';
    final dietType = '${user.dietType ?? "--"}';

    return Scaffold(
      backgroundColor: AppColors.ContainerColor,
      appBar: AppBar(
        backgroundColor: AppColors.ContainerColor,
        title: Text(
          "Personal Details",
          style: GoogleFonts.inriaSans(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 35),
            Container(
              decoration: BoxDecoration(
                color: AppColors.ContainerColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondaryColor, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal Weight',
                          style: GoogleFonts.inriaSans(
                            color: Colors.white.withOpacity(0.73),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          goalWeight,
                          style: GoogleFonts.inriaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
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
                      style: GoogleFonts.inriaSans(
                        color: const Color(0xFF232237),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.ContainerColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondaryColor, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.35),
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
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.35),
                    height: 1,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  ),
                  _infoRow('Date of birth', birthDate, onEdit: () {}),
                  Divider(
                    color: Colors.grey.withOpacity(0.35),
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
                        await updateHealthProfile(gender: newGender);
                      }
                    },
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.35),
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
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.35),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inriaSans(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inriaSans(
              color: Colors.white,
              fontSize: title == 'Daily step goal' ? 17 : 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 13),
          InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: onEdit,
            child: Icon(
              Icons.edit,
              color: Colors.white.withOpacity(0.57),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}
