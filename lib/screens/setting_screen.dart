import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/notification_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);

    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.initializeNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {

         // provider.toggleDailyReminder(provider.isReminderEnabled);
          //provider.toggleDailyReminderDefault(provider.isReminderEnabledDef);

          return Column(
            children: [
              ListTile(
                title: Text(
                  "Enable Daily Reminder Random",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: themeProvider
                          .currentTheme.textTheme.bodyMedium?.color),
                ),
                trailing: Switch(
                  value: provider.isReminderEnabled,
                  onChanged: (value) async {
                    provider.toggleDailyReminder(value);
                  },
                ),
              ),
              ListTile(
                title: Text(
                  "Enable Daily Reminder Default",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: themeProvider
                          .currentTheme.textTheme.bodyMedium?.color),
                ),
                trailing: Switch(
                  value: provider.isReminderEnabledDef,
                  onChanged: (value) async {
                    provider.toggleDailyReminderDefault(value);
                  },
                ),
              ),
              if (!provider.hasPermission)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await provider.requestPermission();
                      await provider.requestExactAlarmPermission();
                    },
                    child: const Text("Request Notification Permission"),
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  // Tampilkan popup dengan daftar notifikasi
                  await showScheduledNotificationsDialog(
                      context, notificationProvider);
                },
                child: const Text("Show Scheduled Notifications"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showScheduledNotificationsDialog(
      BuildContext context, NotificationProvider notificationProvider) async {
    List<PendingNotificationRequest> scheduledNotifications =
        await notificationProvider.getScheduledNotifications();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Scheduled Notifications"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: scheduledNotifications.length,
              itemBuilder: (context, index) {
                final notification = scheduledNotifications[index];
                return ListTile(
                  title: Text("ID: ${notification.id}"),
                  subtitle: Text(
                      "Title: ${notification.title}\nBody: ${notification.body}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await notificationProvider
                          .cancelScheduledNotification(notification.id);
                      Navigator.pop(context); // Tutup dialog
                      await showScheduledNotificationsDialog(
                          context, notificationProvider); // Refresh daftar
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () async {
                await notificationProvider.cancelAllScheduledNotifications();
                Navigator.pop(
                    context); // Tutup dialog setelah menghapus semua notifikasi
              },
              child: const Text("Clear All"),
            ),
          ],
        );
      },
    );
  }
}
