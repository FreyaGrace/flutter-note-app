import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/notification_service.dart';

class PomodoroController extends GetxController {
  // Configurable durations
  var workMinutes = 25.obs;
  var shortBreakMinutes = 5.obs;
  var longBreakMinutes = 15.obs;
  var totalLaps = 4;

  // Timer state
  var minutes = 25.obs;
  var seconds = 0.obs;
  var isRunning = false.obs;
  var isWork = true.obs; // true: work, false: break
  var lap = 1.obs;

  Timer? _timer;
  late Box box; // Hive box to persist session
  DateTime? sessionEnd; // absolute end time of current session

  @override
  void onInit() async {
    super.onInit();
    box = await Hive.openBox('pomodoro');

    // Restore previous session
    if (box.containsKey('sessionEnd')) {
      sessionEnd = box.get('sessionEnd');
      isWork.value = box.get('isWork') ?? true;
      lap.value = box.get('lap') ?? 1;
      totalLaps = box.get('totalLaps') ?? 4;

      _resumeTimer();
    }
  }

  void startTimer() {
    if (isRunning.value) return;

    isRunning.value = true;

    // Calculate absolute session end time if not set
    sessionEnd ??= DateTime.now().add(
      Duration(minutes: isWork.value ? workMinutes.value : _currentBreak()),
    );

    _saveSession();

    _startCountdown();

    // Schedule notification for end of session
    NotificationService.schedule(
      id: 555,
      title: isWork.value ? '🍵 Break Time' : '🍅 Work Time',
      body: isWork.value
          ? (lap.value % totalLaps == 0 ? 'Take a long break!' : 'Take a short break!')
          : 'Back to focus!',
      time: sessionEnd!,
    );
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = sessionEnd!.difference(DateTime.now());

      if (remaining.inSeconds <= 0) {
        _switchSession();
      } else {
        minutes.value = remaining.inMinutes;
        seconds.value = remaining.inSeconds % 60;
      }
    });
  }

  void _resumeTimer() {
    final remaining = sessionEnd!.difference(DateTime.now());

    if (remaining.inSeconds <= 0) {
      _switchSession();
    } else {
      minutes.value = remaining.inMinutes;
      seconds.value = remaining.inSeconds % 60;
      startTimer();
    }
  }

  int _currentBreak() {
    return lap.value % totalLaps == 0 ? longBreakMinutes.value : shortBreakMinutes.value;
  }

  void _switchSession() {
    _timer?.cancel();

    if (isWork.value) {
      // Switch to break
      minutes.value = _currentBreak();
      seconds.value = 0;
      isWork.value = false;
    } else {
      // Switch to work
      minutes.value = workMinutes.value;
      seconds.value = 0;
      isWork.value = true;
      lap.value++;
    }

    // Set new session end
    sessionEnd = DateTime.now().add(Duration(minutes: minutes.value));
    _saveSession();

    // Schedule next session notification
    NotificationService.schedule(
      id: 555,
      title: isWork.value ? '🍵 Break Time' : '🍅 Work Time',
      body: isWork.value
          ? (lap.value % totalLaps == 0 ? 'Take a long break!' : 'Take a short break!')
          : 'Back to focus!',
      time: sessionEnd!,
    );

    startTimer();
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void stopTimer() {
    _timer?.cancel();
    isRunning.value = false;
    isWork.value = true;
    lap.value = 1;
    minutes.value = workMinutes.value;
    seconds.value = 0;
    sessionEnd = null;

    // Clear saved session
    box.delete('sessionEnd');
    box.delete('isWork');
    box.delete('lap');

    // Cancel notification
    NotificationService.cancelPomodoro();
  }

  void resetTimer() {
    stopTimer();
    minutes.value = workMinutes.value;
    seconds.value = 0;
  }

  void setCustomTimes(int work, int shortBreak, int longBreak, int laps) {
    workMinutes.value = work;
    shortBreakMinutes.value = shortBreak;
    longBreakMinutes.value = longBreak;
    totalLaps = laps;
    resetTimer();
  }

  void _saveSession() {
    if (sessionEnd != null) {
      box.put('sessionEnd', sessionEnd);
      box.put('isWork', isWork.value);
      box.put('lap', lap.value);
      box.put('totalLaps', totalLaps);
    }
  }
}
