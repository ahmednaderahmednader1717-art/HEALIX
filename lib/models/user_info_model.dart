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

  UserInfo({
    required this.username,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.gender,
    this.bodyType,
  });

  // ⬇️ تحويل JSON إلى كائن
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      profilePictureUrl: json['profilePictureUrl'],
      bodyType: json['bodyType'],
    );
  }

  // ⬇️ تحويل كائن إلى JSON
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
    };
  }

  // ⬇️ تحميل الصورة مؤقتاً من Google
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
      print("❌ خطأ أثناء تحميل الصورة من Google: $e");
      return null;
    }
  }

  // ⬇️ رفع الصورة إلى السيرفر وتحديث رابطها الجديد
  Future<void> uploadProfilePicture(File imageFile, String token) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://healix.somee.com/api'));
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await dio.post(
        '/User/upload-profile-picture',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final newUrl = _extractUrlFromResponse(response.data);
        if (newUrl != null) {
          profilePictureUrl = newUrl;
          print('✅ تم رفع الصورة بنجاح: $newUrl');
        } else {
          print('⚠️ لم يتم العثور على رابط الصورة في الرد.');
        }
      } else {
        print('❌ فشل رفع الصورة. كود الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ أثناء رفع الصورة: $e');
    }
  }

  // ⬇️ استخراج رابط الصورة من الرد
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
      print('⚠️ خطأ أثناء تحليل الرد: $e');
      return null;
    }
  }
}
