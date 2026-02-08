import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class DrawCanvas extends StatefulWidget {
  final List? initialStrokes;
  const DrawCanvas({super.key, this.initialStrokes});

  @override
  DrawCanvasState createState() => DrawCanvasState();
}

class DrawCanvasState extends State<DrawCanvas> {
  List<List<DrawPoint>> strokes = [];
  List<DrawPoint> currentStroke = [];

  Color selectedColor = Colors.black;
  bool isEraser = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialStrokes != null) {
      loadStrokes(widget.initialStrokes!);
    }
  }

  // ✅ THIS is what NoteDetailPage is calling
  void loadStrokes(List data) {
    strokes.clear();

    for (final stroke in data) {
      final List points = stroke;
      strokes.add(
        points.map((p) {
          return DrawPoint(
            Offset(p['dx'], p['dy']),
            Color(p['color']),
            p['width'],
          );
        }).toList(),
      );
    }

    setState(() {});
  }

  void undo() {
    if (strokes.isNotEmpty) {
      setState(() => strokes.removeLast());
    }
  }

  void setColor(Color color) {
    setState(() {
      selectedColor = color;
      isEraser = false;
    });
  }

  void enableEraser() {
    setState(() => isEraser = true);
  }

  List exportStrokes() {
    return strokes
        .map((stroke) => stroke
            .map((p) => {
                  'dx': p.offset.dx,
                  'dy': p.offset.dy,
                  'color': p.color.value,
                  'width': p.width,
                })
            .toList())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        if (e.kind == PointerDeviceKind.stylus) {
          currentStroke = [
            DrawPoint(
              e.localPosition,
              isEraser ? Colors.transparent : selectedColor,
              isEraser ? 16 : 3,
            )
          ];
          strokes.add(currentStroke);
          setState(() {});
        }
      },
      onPointerMove: (e) {
        if (e.kind == PointerDeviceKind.stylus) {
          currentStroke.add(
            DrawPoint(
              e.localPosition,
              isEraser ? Colors.transparent : selectedColor,
              isEraser ? 16 : 3,
            ),
          );
          setState(() {});
        }
      },
      child: CustomPaint(
        painter: _SketchPainter(strokes),
        size: Size.infinite,
      ),
    );
  }
}

class DrawPoint {
  final Offset offset;
  final Color color;
  final double width;

  DrawPoint(this.offset, this.color, this.width);
}

class _SketchPainter extends CustomPainter {
  final List<List<DrawPoint>> strokes;
  _SketchPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        final paint = Paint()
          ..color = stroke[i].color
          ..strokeWidth = stroke[i].width
          ..strokeCap = StrokeCap.round
          ..blendMode = stroke[i].color == Colors.transparent
              ? BlendMode.clear
              : BlendMode.srcOver;

        canvas.drawLine(
          stroke[i].offset,
          stroke[i + 1].offset,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}