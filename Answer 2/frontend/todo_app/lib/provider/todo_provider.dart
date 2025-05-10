//It's better to use TodoProvider couple with TodoService for
// 1) Make UI reactive
// 2) No boilerplate (setState() everytime it use service)
// 3) Easier to test and maintain

import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../services/todo_service.dart';

class TodoProvider with ChangeNotifier {
  final TodoService _service = TodoService();
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    try {
      final fetched = await _service.fetchTodos();
      _todos = fetched;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  Future<void> addTodo(String title, String detail) async {
    try {
      final todo = await _service.createTodo(title, detail);
      _todos.add(todo);
      await loadTodos();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error add new todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _service.updateTodo(todo);
      await loadTodos();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error update the todo: $e');
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      await _service.flipStatus(id);
      await loadTodos();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error flip status of the todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _service.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      await loadTodos();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error delete the todo: $e');
    }
  }
}