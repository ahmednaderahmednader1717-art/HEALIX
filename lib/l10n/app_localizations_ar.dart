// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get scan => 'مسح';

  @override
  String get progress => 'التقدم';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get todaysTotalNutrition => 'إجمالي التغذية اليومية';

  @override
  String get todaysActivity => 'نشاط اليوم';

  @override
  String nutritionForDate(String date) {
    return 'التغذية ليوم $date';
  }

  @override
  String get recommendedMeals => 'الوجبات المقترحة';

  @override
  String get errorLoadingMeals => 'خطأ في تحميل الوجبات';

  @override
  String get noMealsAvailable => 'لا توجد وجبات متاحة';

  @override
  String get calories => 'السعرات الحرارية';

  @override
  String get fats => 'الدهون';

  @override
  String get protein => 'البروتين';

  @override
  String get carbs => 'الكربوهيدرات';

  @override
  String get steps => 'الخطوات';

  @override
  String get caloriesBurned => 'السعرات المحروقة';

  @override
  String get cal => 'سعرة';

  @override
  String get water => 'الماء';

  @override
  String get logWater => 'تسجيل الماء';

  @override
  String get account => 'الحساب';

  @override
  String get personalDetails => 'البيانات الشخصية';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get language => 'اللغة';

  @override
  String get upgradeToFamilyPlan => 'الترقية إلى خطة العائلة';

  @override
  String get goalsAndTracking => 'الأهداف والمتابعة';

  @override
  String get editNutritionGoals => 'تعديل أهداف التغذية';

  @override
  String get trackDailyIntake => 'متابعة الاستهلاك اليومي';

  @override
  String get weightHistory => 'سجل الوزن';

  @override
  String get supportAndLegal => 'الدعم والقانون';

  @override
  String get requestAFeature => 'طلب ميزة';

  @override
  String get supportEmail => 'البريد الإلكتروني للدعم';

  @override
  String get syncData => 'مزامنة البيانات';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get followUs => 'تابعنا';

  @override
  String get accountActions => 'إجراءات الحساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get error => 'خطأ';

  @override
  String get ok => 'حسناً';

  @override
  String get authTokenNotFound =>
      'لم يتم العثور على رمز المصادقة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String anErrorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String failedToDeleteAccount(String status) {
    return 'فشل في حذف الحساب. الحالة: $status';
  }

  @override
  String get selectLanguage => 'اختر اللغة';
}
