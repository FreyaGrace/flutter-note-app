import 'package:flutter/material.dart';
import 'package:flutter_application_1/controller/note_controller.dart';
import 'package:flutter_application_1/controller/theme_controller.dart';
import 'package:flutter_application_1/widgets/mystical_bg.dart';
import 'package:get/get.dart';
import '../page/note_detailpage.dart';
import '../widgets/cat_fab.dart';

class NotePage extends StatelessWidget {
  NotePage({super.key});

  final NoteController noteController = Get.put(NoteController());
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Note',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => IconButton(
                              icon: Image.asset(
                                themeController.isDark.value
                                   ? 'assets/moon.png'
                                    :'assets/sun.png',
                                width: 28,
                              ),
                              onPressed: themeController.toggleTheme,
                            )),
                      ],
                    ),
                    // FIXED: Added missing closing parenthesis and brace here
                    IconButton(
                      icon: const Icon(Icons.add), 
                      onPressed: () { Get.to(() => const NoteDetailPage()); }
                    ),
                  ],
                ),

                const Divider(),

                // NOTES LIST
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      itemCount: noteController.notes.length,
                      itemBuilder: (context, index) {
                        final note = noteController.notes[index];

                        return Dismissible(
                          key: ValueKey(note.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: const Color.fromARGB(255, 32, 85, 146),
                            // FIXED: Moved the Icon inside the Container
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            noteController.deleteNote(note.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Note deleted')),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              note.content,
                              maxLines:20,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Get.to(() => NoteDetailPage(noteId: note.id));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CatFabMenu(),
    );
  }
}