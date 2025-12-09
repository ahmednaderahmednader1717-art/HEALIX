/// Validation utility functions for form inputs
class Validators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove spaces and dashes for validation
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates required text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }

    return null;
  }

  /// Validates username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a username';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Allow letters, numbers, underscores, and hyphens
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, underscores, and hyphens';
    }

    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validates age (from date of birth)
  static String? validateAge(
    DateTime? dateOfBirth, {
    int minAge = 13,
    int maxAge = 120,
  }) {
    if (dateOfBirth == null) {
      return 'Please select your date of birth';
    }

    final today = DateTime.now();
    final age =
        today.year -
        dateOfBirth.year -
        ((today.month > dateOfBirth.month ||
                (today.month == dateOfBirth.month &&
                    today.day >= dateOfBirth.day))
            ? 0
            : 1);

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    if (age > maxAge) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }

  /// Validates numeric value within range
  static String? validateNumericRange(
    double? value,
    String fieldName, {
    double? min,
    double? max,
  }) {
    if (value == null) {
      return 'Please enter $fieldName';
    }

    if (min != null && value < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && value > max) {
      return '$fieldName must be at most $max';
    }

    return null;
  }
}
