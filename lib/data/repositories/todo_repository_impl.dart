import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local/todo_local_datasource.dart';
import '../datasources/remote/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<TodoEntity>> getTodos() async {
    try {
      // Try fetching from remote
      final remoteTodos = await remoteDataSource.getTodos();
      // Cache locally
      await localDataSource.cacheTodos(remoteTodos);
      // Also include any locally created but unsynced todos at the top so
      // optimistic inserts aren't lost when remote fetch finishes.
      final unsynced = await localDataSource.getUnsyncedTodos();
      if (unsynced.isNotEmpty) {
        // unsynced are TodoModel, which extend TodoEntity
        return [...unsynced, ...remoteTodos];
      }
      return remoteTodos;
    } catch (_) {
      // On error, return cached todos
      final cached = await localDataSource.getCachedTodos();
      final unsynced = await localDataSource.getUnsyncedTodos();
      if (unsynced.isNotEmpty) {
        return [...unsynced, ...cached];
      }
      return cached;
    }
  }

  @override
  Future<TodoEntity> addTodo(String title) async {
    // Create a local todo with a temporary negative id
    final localTodo = TodoModel(id: DateTime.now().millisecondsSinceEpoch * -1, title: title, completed: false);
    await localDataSource.addTodoOffline(localTodo);

    // Attempt sync in background (can be improved with better sync mechanism)
    _syncPendingTodos();

    return localTodo;
  }

  Future<void> _syncPendingTodos() async {
    final unsynced = await localDataSource.getUnsyncedTodos();

    for (var todo in unsynced) {
      try {
  await remoteDataSource.addTodo(todo.title);
  await localDataSource.markTodoAsSynced(todo.id);
      } catch (_) {
      }
    }
  }
}
