import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/local/todo_local_datasource.dart';
import '../data/datasources/remote/todo_remote_datasource.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../domain/repositories/todo_repository.dart';
import '../presentation/bloc/todo_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Data sources
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TodoRepository>(() => TodoRepositoryImpl(sl(), sl()));

  sl.registerFactory<TodoBloc>(() => TodoBloc(todoRepository: sl()));

  // Local data source
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(),
  );

}
