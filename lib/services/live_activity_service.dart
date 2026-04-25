import 'package:live_activities/live_activities.dart';

class LiveActivityService {
  static final LiveActivities _liveActivitiesPlugin = LiveActivities();
  static String? _latestActivityId;
  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      await _liveActivitiesPlugin.init(appGroupId: "group.com.healix.app");
      _isInitialized = true;
      print('Live Activity Service Initialized successfully');
    } catch (e) {
      print('Failed to initialize Live Activity Service: $e');
    }
  }

  static Future<void> updateActivity({
    required double caloriesLeft,
    required double proteinLeft,
    required double carbsLeft,
    required double fatsLeft,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final Map<String, dynamic> data = {
      'caloriesLeft': caloriesLeft.toDouble(),
      'proteinLeft': proteinLeft.toDouble(),
      'carbsLeft': carbsLeft.toDouble(),
      'fatsLeft': fatsLeft.toDouble(),
    };

    print('Requesting Live Activity update: $data');

    try {
      if (_latestActivityId == null) {
        print('Creating new Live Activity...');
        // In 2.4.7, createActivity takes (activityId, data)
        _latestActivityId = await _liveActivitiesPlugin.createActivity(
          'healix_macros',
          data,
        );
        print('Live Activity started with ID: $_latestActivityId');
      } else {
        print('Updating existing Live Activity ID: $_latestActivityId');
        await _liveActivitiesPlugin.updateActivity(_latestActivityId!, data);
        print('Live Activity updated successfully');
      }
    } catch (e) {
      print('Error managing Live Activity: $e');
      _latestActivityId = null;
    }
  }

  static Future<void> stopActivity() async {
    if (_latestActivityId == null) {
      print('No active activity to stop');
      return;
    }

    try {
      await _liveActivitiesPlugin.endActivity(_latestActivityId!);
      print('Live Activity stopped: $_latestActivityId');
      _latestActivityId = null;
    } catch (e) {
      print('Error stopping Live Activity: $e');
    }
  }
}
