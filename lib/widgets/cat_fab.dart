import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/pomodoro.dart';
import 'package:flutter_application_1/page/reminder_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/page/todo_page.dart';

class CatFabMenu extends StatelessWidget {
  const CatFabMenu({super.key});

  @override
  Widget build(BuildContext context) {
     
    return SpeedDial(
  activeChild: const Icon(Icons.close), // optional
  backgroundColor: Colors.transparent,
  overlayOpacity: 0.1,
  spacing: 12,
  spaceBetweenChildren: 8,
  children: [
    SpeedDialChild(
      child: const Icon(Icons.timer),
      label: 'Pomodoro',
      onTap: () {
        Get.to(()=> PomodoroPage());
      },
    ),
    SpeedDialChild(
      child: const Icon(Icons.notifications),
      label: 'Reminders',
      onTap: () {
        Get.to(() => ReminderPage());
      },
    ),
    SpeedDialChild(
      child: const Icon(Icons.check_box),
      label: 'To-Do List',
      onTap: () {
        Get.to(() => TodoPage());
      },
    ),
  ],
  child: Image.asset(
    'assets/cat.png',
    width: 70,
    height: 70,
  ), // <-- move this to the end
);
  }
}