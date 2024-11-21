import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const simpleDelayedTask =
      "be.tramckrijte.workmanagerExample.simpleDelayedTask";

  // Fungsi static untuk callback dispatcher
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      // Panggil fetchRandomRestaurant di dalam callback (pastikan fungsi ini bisa diakses secara statis atau dari instance)
      await NotificationService().fetchRandomRestaurant();
      return Future.value(true);
    });
  }

  Future<void> fetchRandomRestaurant() async {
    final response =
        await http.get(Uri.parse('https://restaurant-api.dicoding.dev/list'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> restaurants = data['restaurants'];
      if (restaurants.isNotEmpty) {
        var randomRestaurant = (restaurants..shuffle()).first;
        String restaurantName = randomRestaurant['name'];
        String restaurantDescription = randomRestaurant['description'];

        await showNotification(restaurantName, restaurantDescription);
      }
    } else {
      throw Exception('Failed to load restaurant data');
    }
  }

  Future<void> showNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'restaurant_reminder_channel',
          'Restaurant Reminder',
          channelDescription: 'Reminder to explore a restaurant',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void scheduleDailyReminder() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    Workmanager().registerOneOffTask(simpleDelayedTask, simpleDelayedTask,
        initialDelay: const Duration(hours: 11, minutes: 00, seconds: 00));
  }
}
