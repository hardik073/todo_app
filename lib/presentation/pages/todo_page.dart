import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/di/injection_container.dart';
import 'package:todo_app/presentation/bloc/todo_bloc.dart';
import 'package:todo_app/presentation/bloc/todo_event.dart';
import 'package:todo_app/presentation/bloc/todo_state.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoBloc>()..add(LoadTodos()),
      child: Scaffold(
        appBar: AppBar(title: const Text('TODOs')),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TodoLoaded) {
              return ListView.builder(
                itemCount: state.todos.length,
                itemBuilder: (_, index) {
                  final todo = state.todos[index];
                  return ListTile(
                    title: Text(todo.title),
                   
                  );
                },
              );
            } else if (state is TodoError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final title = await showDialog<String>(
              context: context,
              builder: (context) {
                final controller = TextEditingController();
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Title'),
                    onSubmitted: (value) {
                      final text = value.trim();
                      if (text.isNotEmpty) Navigator.of(context).pop(text);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) Navigator.of(context).pop(text);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );

            if (title != null && title.isNotEmpty) {
              context.read<TodoBloc>().add(AddTodo(title));
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
