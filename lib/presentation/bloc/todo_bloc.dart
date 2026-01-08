import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/todo_repository.dart';
import '../../domain/entities/todo_entity.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({required this.todoRepository}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await todoRepository.getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('Failed to load todos'));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    final currentState = state;
    
    // If we already have loaded todos, perform an optimistic update and show
    // the new todo at the top immediately. Then sync with repository and
    // replace the optimistic item with the saved one. On failure, revert.
    if (currentState is TodoLoaded) {
      // create a temporary unique negative id for the optimistic todo
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      final optimistic = TodoEntity(
        id: tempId,
        title: event.title,
        completed: false,
      );

      final optimisticList = [optimistic, ...currentState.todos];
      // Emit the optimistic list so UI shows the new todo at the top
      emit(TodoLoaded(optimisticList));

      try {
        final saved = await todoRepository.addTodo(event.title);
        // Replace the optimistic item (by tempId) with the saved one
        final replaced = optimisticList.map((t) {
          return t.id == tempId ? saved : t;
        }).toList(growable: false);
        emit(TodoLoaded(replaced));
      } catch (e) {
        // On failure, revert to the previous list
        emit(TodoLoaded(currentState.todos));
      }
    } else {
      // If todos aren't loaded yet (initial/loading), still perform an
      // optimistic insert so the UI shows the newly added todo at the top
      // without calling getTodos().
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      final optimistic = TodoEntity(
        id: tempId,
        title: event.title,
        completed: false,
      );

      emit(TodoLoaded([optimistic]));

      try {
        final saved = await todoRepository.addTodo(event.title);
        // Replace the optimistic item with the saved one
        emit(TodoLoaded([saved]));
      } catch (e) {
        // On failure, show an error state (or revert to empty list)
        emit(TodoError('Failed to add todo'));
      }
    }
  }
}
