import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/presentation/bloc/todo_event.dart';

import 'di/injection_container.dart' as di;
import 'presentation/bloc/todo_bloc.dart';
import 'presentation/pages/todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      home: BlocProvider<TodoBloc>(
        create: (_) => di.sl<TodoBloc>()..add(LoadTodos()),
        child: const TodoPage(),
      ),
    );
  }
}
