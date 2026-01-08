import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos();
  Future<TodoEntity> addTodo(String title);
}
