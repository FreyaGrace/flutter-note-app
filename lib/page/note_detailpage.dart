import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controller/note_controller.dart';
import '../controller/theme_controller.dart';
import '../widgets/draw_canvas.dart';

class NoteDetailPage extends StatefulWidget {
  final int? noteId;
  const NoteDetailPage({super.key, this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final NoteController controller = Get.find();
  final TextEditingController textController = TextEditingController();
  final GlobalKey<DrawCanvasState> drawKey = GlobalKey();
  final themeController = Get.find<ThemeController>();

  bool _isNew = true;
  int? _currentId;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _currentId = widget.noteId;

    if (widget.noteId != null) {
      final note = controller.getById(widget.noteId!);
      textController.text = note?.content ?? '';
      _isNew = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        drawKey.currentState
            ?.loadStrokes(controller.loadStrokes(widget.noteId!));
      });
    }

    // 🔹 Debounced auto-save while typing (pomodoro-safe)
    textController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 400), () {
        if (_isNew && textController.text.isNotEmpty) {
          _currentId = controller.addNote(textController.text);
          _isNew = false;
        } else if (!_isNew && _currentId != null) {
          controller.editNote(_currentId!, textController.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            DrawCanvas(key: drawKey),

            Padding(
              padding: const EdgeInsets.all(30),
              child: TextField(
                controller: textController,
                autofocus: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 18, height: 1.6),
                decoration: const InputDecoration(
                  hintText: 'Write or draw anywhere…',
                  border: InputBorder.none,
                ),
              ),
            ),

            // 🔹 Top bar (theme reactive only — safe rebuild)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Obx(() => Container(
                    color: themeController.isDark.value
                        ? Colors.grey[900]
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: Get.back),
                        IconButton(
                            icon: const Icon(Icons.undo),
                            onPressed: () =>
                                drawKey.currentState?.undo()),
                        IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: saveNote),
                        IconButton(
                            icon: const Icon(Icons.picture_as_pdf),
                            onPressed: exportPdf),
                      ],
                    ),
                  )),
            ),

            // 🔹 Bottom tools
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _colorButton(Colors.black),
                  _colorButton(Colors.blue),
                  _colorButton(Colors.purple),
                  _colorButton(Colors.red),
                  IconButton(
                    icon: const Icon(Icons.cleaning_services),
                    onPressed: () =>
                        drawKey.currentState?.enableEraser(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color) {
    return GestureDetector(
      onTap: () => drawKey.currentState?.setColor(color),
      child: CircleAvatar(backgroundColor: color, radius: 14),
    );
  }

  void saveNote() {
    if (_currentId != null) {
      controller.editNote(_currentId!, textController.text);
      controller.saveStrokes(
        _currentId!,
        drawKey.currentState!.exportStrokes(),
      );
    }
    Get.back();
  }

  Future<void> exportPdf() async {
    const width = 800;
    const height = 1200;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final drawState = drawKey.currentState!;
    for (final stroke in drawState.strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        final start = stroke[i];
        final end = stroke[i + 1];

        final paint = ui.Paint()
          ..color = start.color
          ..strokeWidth = start.width
          ..strokeCap = ui.StrokeCap.round
          ..blendMode = start.color.value == 0x00000000
              ? ui.BlendMode.clear
              : ui.BlendMode.srcOver;

        canvas.drawLine(start.offset, end.offset, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(textController.text,
                style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            if (bytes != null)
              pw.Image(
                  pw.MemoryImage(bytes.buffer.asUint8List())),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}