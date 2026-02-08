import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  final box = GetStorage();
  var isDark = true.obs;

  @override
  void onInit() {
    isDark.value = box.read('isDark') ?? true;
    super.onInit();
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    box.write('isDark', isDark.value);
    Get.changeThemeMode(
      isDark.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
