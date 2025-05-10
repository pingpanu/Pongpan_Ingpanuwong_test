import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/screens/todo_home.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/provider/todo_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent)
      );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}