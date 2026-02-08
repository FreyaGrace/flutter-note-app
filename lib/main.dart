import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/note_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/theme_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model/reminder.dart';
import 'services/notification_service.dart';

// 🌈 Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF6159DA),
    secondary: Color(0xFF9B6EEE),
    surface: Color(0xFFFFFFFF),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 4,
      color: Color.fromARGB(255, 11, 1, 77), // dark blue on light
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Color(0xFF4A4A6A), // darker gray/blue on light
    ),
  ),
);

// 🌙 Dark Theme
final ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6159DA),
    secondary: Color(0xFF9B6EEE),
    surface: Color(0xFF1A1C4A),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 4,
      color: Color(0xFFB0BFFF), // light blue for dark mode
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Color(0xFFDDDDFF), // light gray/blue for dark mode
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());

  await NotificationService.init();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        themeMode: themeController.isDark.value
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: NotePage(),
      ),
    );
  }
}
