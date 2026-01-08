import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/remote/todo_remote_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;

  TodoRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TodoEntity>> getTodos() async {
    return await remoteDataSource.getTodos();
  }

  @override
  Future<TodoEntity> addTodo(String title) async {
    return await remoteDataSource.addTodo(title);
  }
}
