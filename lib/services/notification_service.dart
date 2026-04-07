import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        log('Notification clicked: ${details.payload}');
      },
    );

    // Re-schedule water reminders if enabled
    final prefs = await SharedPreferences.getInstance();
    final waterEnabled = prefs.getBool('water_reminders_enabled') ?? false;
    if (waterEnabled) {
      log('Water reminders enabled, re-scheduling...');
      await scheduleWaterReminders();
    }

    log('Notification Service Initialized');
  }

  /// Schedules a reminder for 8:00 PM today.
  /// If [loggedToday] is true, it cancels any existing reminder for today.
  static Future<void> updateStreakReminder(bool loggedToday) async {
    if (loggedToday) {
      log('Food logged today, cancelling reminder.');
      await _notificationsPlugin.cancel(100); // Unique ID for streak reminder
      return;
    }

    log('Scheduling streak reminder for 8:00 PM.');

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 8:00 PM
      0,
    );

    // If it's already past 8:00 PM, skip today to avoid immediate notification.
    if (scheduledDate.isBefore(now)) {
      log('Already past 8:00 PM, skipping today.');
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      100,
      'Don\'t lose your streak! 🔥',
      'You haven\'t logged any food yet today. Log a meal now to keep your streak alive!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription:
              'Notifications to remind you to log food and keep your streak.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'streak_reminder',
    );
  }

  /// Schedules 8 water reminders throughout the day.
  static Future<void> scheduleWaterReminders() async {
    final List<int> hours = [8, 10, 12, 14, 16, 18, 20, 22];
    final List<String> messages = [
      "Time to hydrate!",
      "Drink some water to stay energized!",
      "Stay fresh! Grab a glass of water.",
      "Hydration check! Your body will thank you.",
      "Water break!",
      "Keep that glow! Drink some water.",
      "Feeling thirsty? Drink up!",
      "One last glass for today!",
    ];

    for (int i = 0; i < hours.length; i++) {
      final hour = hours[i];
      final message = messages[i];
      final id = 200 + i; // IDs 200-207

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        0,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        "Water Reminder",
        message,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders',
            'Water Reminders',
            channelDescription: 'Periodic reminders to drink water.',
            importance: Importance.low,
            priority: Priority.low,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        payload: 'water_reminder',
      );
    }
    log('8 Water Reminders scheduled successfully.');
  }

  /// Cancels all scheduled water reminders.
  static Future<void> cancelWaterReminders() async {
    for (int i = 0; i < 8; i++) {
      await _notificationsPlugin.cancel(200 + i);
    }
    log('All water reminders cancelled.');
  }
}
