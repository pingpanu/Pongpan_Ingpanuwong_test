import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/provider/todo_provider.dart';
import 'package:todo_app/widgets/todo_item.dart';
import 'package:todo_app/model/todo.dart';

//This is home screen
class TodoHome extends StatefulWidget{
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TodoProvider>(context, listen: false).loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15,),
            child: Column(
              children: [
                for (Todo todo in provider.todos)
                  TodoItem(todo: todo,),
              ],
            ),
          ),
          //This is pink button to add Todos
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(bottom: 20,right: 20,),
              child: FloatingActionButton(
                onPressed: () {
                  showTodoForm(context);
                },
                backgroundColor: addPink,
                foregroundColor: detailWhite,
                child: Icon(Icons.add, size: 35),
              ),
            ),
          )
        ],
      )
    );
  }

  Future<dynamic> showTodoForm(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final detailController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: Text("Add New Todo"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title cannot be blank";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: detailController,
                  decoration: InputDecoration(labelText: "Detail"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Detail cannot be blank";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final title = titleController.text.trim();
                  final detail = detailController.text.trim();

                  final navigator = Navigator.of(context); // Save the navigator before await
                  await Provider.of<TodoProvider>(context, listen: false).addTodo(title, detail);
                  navigator.pop(); // Use saved reference
                  }
                },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgGrey,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
          'TODO APP', 
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: textBlack,
          ),
        ),
      ]),
    );
  }
}