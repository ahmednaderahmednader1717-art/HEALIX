import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

void main() async {
  // 🔁 رابط السيرفر الأصلي (سواء HTTP أو HTTPS)
  const String target = 'http://healix.somee.com/api';

  // ✅ هندعم HTTPS كمان باستخدام override بسيط
  HttpOverrides.global = _AllowAllCerts();

  // 🔁 إنشاء البروكسي اللي بيمرر الطلبات
  final handler = const Pipeline()
      .addMiddleware(logRequests()) // لعرض الطلبات في الكونسول
      .addHandler(proxyHandler(target));

  // 🧩 تشغيل السيرفر المحلي
  final server = await serve(handler, InternetAddress.loopbackIPv4, 8080);
  print('✅ Proxy running at http://${server.address.host}:${server.port}/');
  print('🔁 Forwarding requests to $target');
  print('🌐 Supports both HTTP and HTTPS now!');
}

// 🧠 كلاس يسمح بأي شهادة SSL (يحل مشكلة "CERTIFICATE_VERIFY_FAILED")
class _AllowAllCerts extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
