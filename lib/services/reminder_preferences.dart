import 'package:shared_preferences/shared_preferences.dart';

class ReminderPreferences {
  static Future<void> setReminderStatus(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('daily_reminder', isEnabled);
  }

  static Future<bool> getReminderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('daily_reminder') ?? false;
  }
}
