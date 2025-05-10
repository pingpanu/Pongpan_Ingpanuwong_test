//This file is to handle API calls

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_app/model/todo.dart';

class TodoService {
  final String baseUrl = 'http://localhost:8080/api/todos';

  Future<List<Todo>> fetchTodos() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List jsonList = json.decode(res.body);
      return jsonList.map((e) => Todo.fromJson(e)).toList();
    }
    throw Exception('Failed to load todos');
  }

  Future<Todo> createTodo(String title, String detail) async {
    final res = await http.post(Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'detail': detail}));
    return Todo.fromJson(json.decode(res.body));
  }

  Future<void> updateTodo(Todo todo) async {
    await http.put(
      Uri.parse('$baseUrl/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': todo.title, 'detail': todo.detail}),
    );
  }

  Future<void> flipStatus(int id) async {
    await http.put(Uri.parse('$baseUrl/$id/flip-status'));
  }

  Future<void> deleteTodo(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}