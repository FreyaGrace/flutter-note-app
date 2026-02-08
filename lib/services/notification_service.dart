import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  // 🔔 Single reminder
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 💧 Hourly water reminder
  static Future<void> hourlyWater(bool enabled) async {
    if (!enabled) {
      await _plugin.cancel(999);
      return;
    }

    await _plugin.periodicallyShow(
      999,
      '💧 Drink Water',
      'Stay hydrated!',
      RepeatInterval.hourly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Water Reminder',
          importance: Importance.high,
        ),
      ),
    );
  }


  // 🍅 Schedule Pomodoro notification at a specific time
static Future<void> schedulePomodoro({
  required int id,
  required String title,
  required String body,
  required DateTime time,
}) async {
  await _plugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(time, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

  static Future<void> cancelPomodoro() async {
  await _plugin.cancel(555);
}
 static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
