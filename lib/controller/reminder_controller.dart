import 'package:get/get.dart';
import '../model/reminder.dart';
import '../services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReminderController extends GetxController {
  var reminders = <Reminder>[].obs;
  var waterEnabled = true.obs;

  late Box<Reminder> reminderBox;

  @override
  void onInit() {
    super.onInit();
    _initializeReminders();
  }

  Future<void> _initializeReminders() async {
    // Open Hive box
    reminderBox = await Hive.openBox<Reminder>('reminders');

    // Load all reminders and sort by time
    reminders.value = reminderBox.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    // Schedule notifications for future reminders
    for (var r in reminders.where((r) => r.time.isAfter(DateTime.now()))) {
      NotificationService.schedule(
        id: r.id,
        title: r.title,
        body: r.note ?? 'Reminder time!',
        time: r.time,
      );
    }

    // Schedule hourly water reminder
    NotificationService.hourlyWater(waterEnabled.value);
  }

  void toggleWater(bool value) {
    waterEnabled.value = value;
    NotificationService.hourlyWater(value);
  }

  Future<void> addReminder({
    required String title,
    required DateTime time,
    String? note, // optional
  }) async {
    // Create a new reminder without ID
    final reminder = Reminder(
      id: 0, // placeholder, will be updated by Hive
      title: title,
      note: note,
      time: time,
    );

    // Save to Hive, Hive auto-generates the key
    final int id = await reminderBox.add(reminder);
    reminder.id = id;

    // Add to observable list
    reminders.add(reminder);

    // Schedule notification
    NotificationService.schedule(
      id: id,
      title: reminder.title,
      body: note ?? 'Reminder time!',
      time: reminder.time,
    );
    
  }
  Future<void> deleteReminder(int id) async {
    await reminderBox.delete(id);
    reminders.removeWhere((r) => r.id == id);
    NotificationService.cancel(id);
  }
  
}