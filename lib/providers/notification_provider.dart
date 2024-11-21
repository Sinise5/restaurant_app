import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider with ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationService notificationService = NotificationService();

  bool _hasPermission = false;
  bool _isReminderEnabled = false;
  bool _isReminderEnabledDef = false;

  bool get hasPermission => _hasPermission;
  bool get isReminderEnabled => _isReminderEnabled;
  bool get isReminderEnabledDef => _isReminderEnabledDef;

  Future<void> initializeNotifications() async {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
    await requestExactAlarmPermission();

    tz_data.initializeTimeZones();

    final jakarta = tz.getLocation('Asia/Jakarta');

    await _checkNotificationPermission();
    await _loadReminderSetting();
  }

  Future<void> toggleDailyReminder(bool isEnabled) async {
    _isReminderEnabled = isEnabled;
    await _saveReminderSetting(isEnabled);
    notifyListeners();

    if (_isReminderEnabled) {
      notificationService.scheduleDailyReminder();
    }
  }

  Future<void> toggleDailyReminderDefault(bool isEnabled) async {
    _isReminderEnabledDef = isEnabled;
    await _saveReminderSettingDef(isEnabled);
    notifyListeners();

    if (_isReminderEnabledDef) {
      await scheduleDailyReminder();
    }
  }

  Future<void> _saveReminderSetting(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', isEnabled);
  }

  Future<void> _saveReminderSettingDef(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled_def', isEnabled);
  }

  Future<void> _loadReminderSetting() async {
    final prefs = await SharedPreferences.getInstance();
    bool ShRE = prefs.getBool('daily_reminder_enabled') ?? false;
    bool ShREDef = prefs.getBool('daily_reminder_enabled_def') ?? false;

    if(ShRE) { _isReminderEnabled=ShRE; }
    if(ShREDef) { _isReminderEnabledDef=ShREDef; }

    notifyListeners();
  }

  Future<void> _checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      _hasPermission = true;
    } else {
      _hasPermission = false;
    }

    notifyListeners();
  }

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      _hasPermission = true;
    } else {
      _hasPermission = false;
    }

    notifyListeners();
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> pendingnotif() async {
    List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var notification in pendingNotifications) {
      debugPrint(
          'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
  }

  Future<void> scheduleDailyReminder() async {
    if (!_hasPermission || !_isReminderEnabledDef) {
      print(
          "Permission not granted for notifications {$_hasPermission} or Daily Reminder is disabled {$_isReminderEnabledDef}.");
      return;
    }

    final now = DateTime.now();
    final jakarta = tz.getLocation('Asia/Jakarta');
    final localNow = tz.TZDateTime.from(now, jakarta);

    final scheduledTime = tz.TZDateTime(
        jakarta, localNow.year, localNow.month, localNow.day, 11, 00);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'Jangan lupa makan siang!',
      scheduledTime.isBefore(localNow)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Reminder for daily activities',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> testNotification() async {
    if (!_hasPermission) {
      print("Permission not granted for notifications.");
      return;
    }

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification. Click to check if it works.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification_channel',
          'Test Notification',
          channelDescription: 'A test notification to check functionality.',
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelScheduledNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    notifyListeners();
  }

  Future<void> cancelAllScheduledNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    notifyListeners();
  }
}
