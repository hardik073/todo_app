import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<int> addTodoOffline(TodoModel todo);
  Future<List<TodoModel>> getUnsyncedTodos();
  Future<void> markTodoAsSynced(int id);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static const _databaseName = 'todo_app.db';
  static const _databaseVersion = 1;
  static const tableTodos = 'todos';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, _databaseName);
    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTodos (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL,
        isSynced INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final db = await database;
    final maps = await db.query(tableTodos);
    return maps.map((e) => TodoModel(
      id: e['id'] as int,
      title: e['title'] as String,
      completed: (e['completed'] as int) == 1,
    )).toList();
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final db = await database;
    final batch = db.batch();
    await db.delete(tableTodos); // Clear old cache
    for (var todo in todos) {
      batch.insert(tableTodos, {
        'id': todo.id,
        'title': todo.title,
        'completed': todo.completed ? 1 : 0,
        'isSynced': 1,
      });
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<int> addTodoOffline(TodoModel todo) async {
    final db = await database;
    return db.insert(tableTodos, {
      'id': todo.id,
      'title': todo.title,
      'completed': todo.completed ? 1 : 0,
      'isSynced': 0,
    });
  }
  @override
  Future<List<TodoModel>> getUnsyncedTodos() async {
    final db = await database;
    final maps = await db.query(tableTodos, where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((e) => TodoModel(
      id: e['id'] as int,
      title: e['title'] as String,
      completed: (e['completed'] as int) == 1,
    )).toList();
  }

  @override
  Future<void> markTodoAsSynced(int id) async {
    final db = await database;
    await db.update(tableTodos, {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}