class Todo {
  final int id;
  String title;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory Todo.fromMap(Map<String, dynamic> map) => Todo(
        id: map['id'],
        title: map['title'],
        isDone: map['isDone'],
      );
}
