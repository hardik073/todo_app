import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required int id,
    required String title,
    required bool completed,
  }) : super(id: id, title: title, completed: completed);

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['todo'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todo': title,
      'completed': completed,
      'userId': 1, // DummyJSON requires this
    };
  }
}
