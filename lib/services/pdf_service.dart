import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/draw_canvas.dart';
import 'package:flutter/material.dart';


Future<void> exportPdf(String text, DrawCanvasState canvasState) async {
  // Capture canvas strokes to an image
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
 //inal size = const ui.Size(800, 1200);

  // Draw strokes with color + width
  for (final List<DrawPoint> stroke in canvasState.strokes) {
    for (int i = 0; i < stroke.length - 1; i++) {
      final start = stroke[i];
      final end = stroke[i + 1];

      final paint = ui.Paint()
        ..color = start.color
        ..strokeWidth = start.width
        ..strokeCap = ui.StrokeCap.round
        ..blendMode =
            start.color == Colors.transparent ? ui.BlendMode.clear : ui.BlendMode.srcOver;

      canvas.drawLine(start.offset, end.offset, paint);
    }
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(800, 1200);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  // Create PDF
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (_) => pw.Column(
        children: [
          pw.Text(text, style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 20),
          if (bytes != null)
            pw.Image(pw.MemoryImage(bytes.buffer.asUint8List())),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) => pdf.save());
}
