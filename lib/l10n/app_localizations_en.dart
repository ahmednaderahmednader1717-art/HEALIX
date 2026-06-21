// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get scan => 'Scan';

  @override
  String get progress => 'Progress';

  @override
  String get profile => 'Profile';

  @override
  String get todaysTotalNutrition => 'Today\'s Total Nutrition';

  @override
  String get todaysActivity => 'Today\'s Activity';

  @override
  String nutritionForDate(String date) {
    return 'Nutrition for $date';
  }

  @override
  String get recommendedMeals => 'Recommended Meals';

  @override
  String get errorLoadingMeals => 'Error loading meals';

  @override
  String get noMealsAvailable => 'No meals available';

  @override
  String get calories => 'Calories';

  @override
  String get fats => 'Fats';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get steps => 'Steps';

  @override
  String get caloriesBurned => 'Calories burned';

  @override
  String get cal => 'cal';

  @override
  String get water => 'Water';

  @override
  String get logWater => 'Log Water';

  @override
  String get account => 'Account';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get upgradeToFamilyPlan => 'Upgrade to Family Plan';

  @override
  String get goalsAndTracking => 'Goals & Tracking';

  @override
  String get editNutritionGoals => 'Edit Nutrition Goals';

  @override
  String get trackDailyIntake => 'Track Daily Intake';

  @override
  String get weightHistory => 'Weight History';

  @override
  String get supportAndLegal => 'Support & Legal';

  @override
  String get requestAFeature => 'Request a Feature';

  @override
  String get supportEmail => 'Support Email';

  @override
  String get syncData => 'Sync Data';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get followUs => 'Follow Us';

  @override
  String get accountActions => 'Account Actions';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get authTokenNotFound =>
      'Authentication token not found. Please log in again.';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String failedToDeleteAccount(String status) {
    return 'Failed to delete account. Status: $status';
  }

  @override
  String get selectLanguage => 'Select Language';
}
