import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Default public constructor for testing and subclass support
  NotificationService();

  /// Initialize notifications plugin and setup Android channels
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      
      // Attempt to configure local timezone
      try {
        // Set fallback to UTC if device timezone resolution errors
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (e) {
        debugPrint("AURA NOTIFICATIONS: Timezone location boot bypass: $e");
      }

      // Configure Android specific settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint("AURA NOTIFICATIONS: Tapped alarm payload: ${details.payload}");
        },
      );

      // Create high-fidelity notification channel
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'aura_study_channel',
            'Aura Study Planner',
            description: 'Study Session Reminders',
            importance: Importance.max,
            playSound: true,
          ),
        );
      }

      _isInitialized = true;
      debugPrint("AURA NOTIFICATIONS: Initialized successfully.");
    } catch (e) {
      debugPrint("AURA NOTIFICATIONS ERROR: Failed initialization: $e");
    }
  }

  /// Request permissions for Android 13+ devices
  Future<void> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint("AURA NOTIFICATIONS: Request permission bypassed or failed: $e");
    }
  }

  /// Schedule a local notification at a specific date/time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await init();
    try {
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        debugPrint("AURA NOTIFICATIONS: Scheduled time is in the past, triggering immediately.");
        await showNotification(id: id, title: title, body: body);
        return;
      }

      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aura_study_channel',
            'Aura Study Planner',
            channelDescription: 'Study Session Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("AURA NOTIFICATIONS: Scheduled alarm id=$id at $tzScheduledTime");
    } catch (e) {
      debugPrint("AURA NOTIFICATIONS ERROR: Failed to schedule alarm, falling back to show immediately: $e");
      // Fallback: Show immediately if zoned schedule fails due to system restriction
      await showNotification(id: id, title: title, body: body);
    }
  }

  /// Trigger immediate alert notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aura_study_channel',
            'Aura Study Planner',
            channelDescription: 'Study Session Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint("AURA NOTIFICATIONS ERROR: Failed to show alarm: $e");
    }
  }

  /// Cancel specific scheduled notification
  Future<void> cancelNotification(int id) async {
    await init();
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint("AURA NOTIFICATIONS: Cancelled alarm id=$id");
    } catch (e) {
      debugPrint("AURA NOTIFICATIONS ERROR: Failed to cancel alarm: $e");
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await init();
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint("AURA NOTIFICATIONS: Purged all alarms.");
    } catch (e) {
      debugPrint("AURA NOTIFICATIONS ERROR: Failed to clear alarms: $e");
    }
  }
}
