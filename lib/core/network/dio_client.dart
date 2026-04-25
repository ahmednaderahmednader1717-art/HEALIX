import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  
  dio.interceptors.add(LogInterceptor(
    requestBody: false, 
    responseBody: false,
    logPrint: (obj) {},
  ));
  
  return dio;
});
