import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> addTodo(String title);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final http.Client client;

  TodoRemoteDataSourceImpl(this.client);

  static const baseUrl = 'https://dummyjson.com/todos';

  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await client.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List todos = decoded['todos'];

      return todos.map((e) => TodoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  @override
  Future<TodoModel> addTodo(String title) async {
    final response = await client.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'todo': title,
        'completed': false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TodoModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }
}
