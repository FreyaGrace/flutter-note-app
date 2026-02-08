class Note {
  final int id;
  String content;
  List<Map<String, double>> strokes;

  Note({
    required this.id,
    required this.content,
    this.strokes = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'strokes': strokes,
      };

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      strokes:
          List<Map<String, double>>.from(map['strokes'] ?? []),
    );
  }
}
