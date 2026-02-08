import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/note.dart';

class NoteController extends GetxController {
  final box = GetStorage();
  var notes = <Note>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  void fetchNotes() {
    final stored = box.read<List>('notes') ?? [];
    notes.assignAll(
      stored.map((e) => Note.fromMap(Map<String, dynamic>.from(e))),
    );
  }

int addNote(String content) {
  final id = DateTime.now().millisecondsSinceEpoch;
  notes.add(Note(id: id, content: content));
  saveNotes();
  return id;
}

  void editNote(int id, String content) {
    final index = notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      notes[index].content = content;
      saveNotes();
    }
  }

  Note? getById(int id) {
    return notes.firstWhereOrNull((n) => n.id == id);
  }

void saveNotes() {
  box.write('notes', notes.map((e) => e.toMap()).toList());
}

  // 🎨 DRAWINGS
  void saveStrokes(int noteId, List strokes) {
    box.write('strokes_$noteId', strokes);
    saveNotes();
  }

  List loadStrokes(int noteId) {
    return box.read<List>('strokes_$noteId') ?? [];
  }
  void deleteNote(int id) {
    notes.removeWhere((note) => note.id == id);
    saveNotes(); // <-- important to persist the deletion
  }
}

