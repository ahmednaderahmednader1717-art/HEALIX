import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];
  static const _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<bool> _requestPermissions() async {
    await _health.configure();
    return _health.requestAuthorization(_types, permissions: _permissions);
  }

  /// Fetches today's total step count.
  Future<int?> getTodaySteps() async {
    try {
      if (!await _requestPermissions()) return null;
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return _health.getTotalStepsInInterval(midnight, now);
    } catch (_) {
      return null;
    }
  }

  /// Fetches today's active calories burned in kcal.
  Future<double?> getTodayCaloriesBurned() async {
    try {
      if (!await _requestPermissions()) return null;
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
      );
      return data.fold<double>(
        0.0,
        (sum, e) => sum + (e.value as NumericHealthValue).numericValue.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}
