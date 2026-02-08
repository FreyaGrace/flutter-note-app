import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? note; // optional

  @HiveField(3)
  DateTime time;

  @HiveField(4)
  bool repeatHourly;

  Reminder({
    required this.id,
    required this.title,
    this.note,
    required this.time,
    this.repeatHourly = false,
  });
}
