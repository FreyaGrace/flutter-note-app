import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/todo.dart';

class TodoController extends GetxController {
  final box = GetStorage();
  var todos = <Todo>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  void loadTodos() {
    final data = box.read<List>('todos');
    if (data != null) {
      todos.assignAll(data.map((e) => Todo.fromMap(e)));
    }
  }

  void addTodo(String title) {
    final id = todos.isNotEmpty ? todos.last.id + 1 : 1;
    todos.add(Todo(id: id, title: title));
    saveTodos();
  }

  void toggleTodo(int index) {
    todos[index].isDone = !todos[index].isDone;
    todos.refresh();
    saveTodos();
  }

  void deleteTodo(int index) {
    todos.removeAt(index);
    saveTodos();
  }

  void saveTodos() {
    box.write('todos', todos.map((e) => e.toMap()).toList());
  }
}
