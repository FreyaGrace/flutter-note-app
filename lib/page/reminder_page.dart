import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/mystical_bg.dart';
import '../controller/reminder_controller.dart';

class ReminderPage extends StatelessWidget {
  final ReminderController c = Get.put(ReminderController());

  ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: MysticBackground(
        child: Obx(() {
          // If no reminders, show "No reminders yet"
          if (c.reminders.isEmpty) {
            return const Center(
              child: Text('No reminders yet'),
            );
          }

          // Otherwise, show reminders list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: c.reminders.length + 1, // +1 for the water toggle
            itemBuilder: (context, index) {
              if (index == 0) {
                // First item is the water toggle
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('💧 Hourly Water Reminder'),
                      value: c.waterEnabled.value,
                      onChanged: c.toggleWater,
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                  ],
                );
              }

              final r = c.reminders[index - 1]; // adjust index because of toggle

              return Dismissible(
                key: ValueKey(r.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await c.deleteReminder(r.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder deleted')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(r.title),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd – HH:mm').format(r.time),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String title = '';
              String note = '';
              DateTime selectedTime =
                  DateTime.now().add(const Duration(minutes: 10));

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add Reminder'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                            onChanged: (val) => title = val,
                          ),
                          TextField(
                            decoration: const InputDecoration(
                                labelText: 'Note (optional)'),
                            onChanged: (val) => note = val,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date == null) return;

                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time == null) return;

                              setState(() {
                                selectedTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            },
                            child: const Text('Pick Date & Time'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selected: ${DateFormat('yyyy-MM-dd – HH:mm').format(selectedTime)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (title.isEmpty) return;

                          await c.addReminder(
                            title: title,
                            time: selectedTime,
                            note: note.isEmpty ? null : note,
                          );

                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}