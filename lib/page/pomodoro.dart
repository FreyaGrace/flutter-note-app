import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/pomodoro_controller.dart';
import '../widgets/mystical_bg.dart';

class PomodoroPage extends StatelessWidget {
  PomodoroPage({super.key});

  final PomodoroController controller = Get.put(PomodoroController());

  String formatTime(int min, int sec) =>
      '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        
        child: Obx(
          () => Stack(
            children: [
              IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: Get.back,
                    ),
              /// 🌙 WORK GIF (behind timer)
              if (controller.isWork.value)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 350, // resize work gif here
                    child: Image.asset(
                      'assets/pomodoro.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              /// 💤 BREAK GIF (corner)
              if (!controller.isWork.value)
                Positioned(
                  top: -16,
                  right: -16,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/pomodoro2.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              /// ⏱ TIMER BOX (dynamic size, no overflow)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
                    children: [
                      Text(
                        controller.isWork.value ? "Work" : "Break",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        formatTime(
                          controller.minutes.value,
                          controller.seconds.value,
                        ),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: controller.isRunning.value
                                ? controller.pauseTimer
                                : controller.startTimer,
                            child: Text(
                              controller.isRunning.value ? 'Pause' : 'Start',
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: controller.resetTimer,
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                       ElevatedButton(
                            onPressed: controller.stopTimer,
                            child: const Text('Stop'),
                          ),

                      const SizedBox(height: 20),

                      Text(
                        "Lap ${controller.lap.value} / ${controller.totalLaps}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () => openSettingsDialog(context),
                        child: const Text('Customize Pomodoro'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ⚙ Settings dialog (unchanged logic)
  void openSettingsDialog(BuildContext context) {
    final workCtrl =
        TextEditingController(text: controller.workMinutes.value.toString());
    final shortBreakCtrl =
        TextEditingController(text: controller.shortBreakMinutes.value.toString());
    final longBreakCtrl =
        TextEditingController(text: controller.longBreakMinutes.value.toString());
    final lapsCtrl =
        TextEditingController(text: controller.totalLaps.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customize Pomodoro'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: workCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Work (minutes)'),
              ),
              TextField(
                controller: shortBreakCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Short Break (minutes)'),
              ),
              TextField(
                controller: longBreakCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Long Break (minutes)'),
              ),
              TextField(
                controller: lapsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Laps'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.totalLaps =
                  int.tryParse(lapsCtrl.text) ?? controller.totalLaps;

            controller.setCustomTimes(
  int.tryParse(workCtrl.text) ?? controller.workMinutes.value,
  int.tryParse(shortBreakCtrl.text) ?? controller.shortBreakMinutes.value,
  int.tryParse(longBreakCtrl.text) ?? controller.longBreakMinutes.value,
  int.tryParse(lapsCtrl.text) ?? controller.totalLaps, // ✅ add this
);

              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
