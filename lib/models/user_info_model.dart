import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class UserInfo {
  String username;
  String email;
  String fullName;
  String? phoneNumber;
  String? profilePictureUrl;
  DateTime? dateOfBirth;
  String? gender;
  String? bodyType;
  String? dietType;
  double? userHeight; // تغيير int? إلى double?
  double? userWeight; // تغيير int? إلى double?
  double? userGoalWeight; // تغيير int? إلى double?

  UserInfo({
    required this.username,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.gender,
    this.bodyType,
    this.dietType,
    this.userHeight,
    this.userWeight,
    this.userGoalWeight,
  });

  // تحويل JSON إلى كائن مع علاج النوع
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      fullName: json['fullName'] ?? "",
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      profilePictureUrl: json['profilePictureUrl'],
      bodyType: json['bodyType'],
      dietType: json['dietType'],
      userHeight: (json['height'] as num?)?.toDouble(),
      userWeight: (json['weight'] as num?)?.toDouble(),
      userGoalWeight: (json['goalWeight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'profilePictureUrl': profilePictureUrl,
      'bodyType': bodyType,
      'dietType': dietType,
      'height': userHeight,
      'weight': userWeight,
      'goalWeight': userGoalWeight,
    };
  }

  // تحميل الصورة من الإنترنت (اختياري)
  static Future<File?> downloadProfileImage(String imageUrl) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(response.data!);
      return file;
    } catch (e) {
      print("❌ خطأ أثناء تحميل الصورة: $e");
      return null;
    }
  }

  // رفع صورة البروفايل
  Future<String?> uploadProfilePicture(File imageFile, {String? token}) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://healix26.somee.com/api'));
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await dio.post(
        '/User/upload-profile-picture',
        data: formData,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final newUrl = _extractUrlFromResponse(response.data);
        if (newUrl != null) {
          profilePictureUrl = newUrl;
          print('✅ تم رفع الصورة: $newUrl');

          // ✅ تحديث البروفايل بالصورة الجديدة
          try {
            await dio.put(
              '/User/update-profile-picture',
              data: {'profilePictureUrl': newUrl},
              options: Options(
                headers: {
                  if (token != null) 'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              ),
            );
            print("✅ Profile picture updated in account");
          } catch (updateError) {
            print("⚠️ Failed to update profile picture in account: $updateError");
          }

          return newUrl;
        }
        print('⚠️ لم يتم إيجاد رابط الصورة في الرد.');
        return null;
      } else {
        print(
          '❌ فشل رفع الصورة. Status: ${response.statusCode} Data: ${response.data}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception رفع الصورة: $e');
      return null;
    }
  }

  // استخراج الرابط من الرد
  String? _extractUrlFromResponse(dynamic responseBody) {
    try {
      if (responseBody is Map<String, dynamic>) {
        return responseBody['url'] ?? responseBody['profilePictureUrl'];
      }
      if (responseBody is String) {
        final decoded = jsonDecode(responseBody);
        return decoded['url'] ?? decoded['profilePictureUrl'];
      }
      return null;
    } catch (e) {
      print('⚠️ تحليل الرد فشل: $e');
      return null;
    }
  }


  UserInfo copyWith({
    String? username,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? bodyType,
    String? dietType,
    double? userHeight,
    double? userWeight,
    double? userGoalWeight,
  }) {
    return UserInfo(
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bodyType: bodyType ?? this.bodyType,
      dietType: dietType ?? this.dietType,
      userHeight: userHeight ?? this.userHeight,
      userWeight: userWeight ?? this.userWeight,
      userGoalWeight: userGoalWeight ?? this.userGoalWeight,
    );
  }

}
