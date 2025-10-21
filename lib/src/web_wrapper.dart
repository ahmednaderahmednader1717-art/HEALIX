import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 🧠 أنشئ كائن GoogleSignIn واحد بمعلومات صحيحة
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '664346993317-p759gclcv2jt2avu18tg0efkdkv28i21.apps.googleusercontent.com', // ✅ هذا هو Client ID الخاص بالويب
  scopes: ['email', 'profile'],
);

// دالة لتسجيل الدخول على الويب
Future<GoogleSignInAccount?> signInWithGoogle() async {
  try {
    // نعمل signOut أول عشان ما تبقى جلسة قديمة تسبب إلغاء تلقائي
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();

    final user = await _googleSignIn.signIn();
    print("✅ Web Google Sign-In success: ${user?.email}");
    return user;
  } catch (e) {
    print("❌ Web Google Sign-In error: $e");
    return null;
  }
}

// زر لتجربة تسجيل الدخول (اختياري فقط)
Widget renderButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: ElevatedButton.icon(
      icon: const Icon(Icons.login),
      label: const Text('Sign in with Google'),
      onPressed: () async {
        final user = await signInWithGoogle();
        if (user != null) {
          print('✅ Logged in as: ${user.email}');
        } else {
          print('⚠️ Sign-in failed or cancelled');
        }
      },
    ),
  );
}
