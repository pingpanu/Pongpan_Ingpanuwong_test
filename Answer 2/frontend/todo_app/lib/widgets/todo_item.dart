import 'package:flutter/material.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/model/todo.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/provider/todo_provider.dart';

class TodoItem extends StatelessWidget {

  final Todo todo;

  const TodoItem({super.key, required this.todo,});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          greenTitleBar(context),
          whiteDetailBar(),
        ],
      ),
    );
  }

  Container whiteDetailBar() {
    return Container(
          padding: EdgeInsets.symmetric(vertical:8 , horizontal:20 ,),
          decoration: BoxDecoration(
            color: detailWhite,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Text( 
            todo.detail,
            style: TextStyle(
              fontSize:14,
              color: textBlack,
              decoration: todo.completed ? TextDecoration.lineThrough : null,
            ),
          ),
        );
  }

  Container greenTitleBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical:8 , horizontal:20 ,),
      decoration: BoxDecoration(
        color: titleGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      child: Row(
        children: [

          //Button to send flipStatus API
          GestureDetector(
            onTap: () async {
              await Provider.of<TodoProvider>(context, listen: false).toggleStatus(todo.id);
            },
            child: Icon(
              todo.completed? Icons.check_box: Icons.check_box_outline_blank,
              color: fbPurple,
            ),
          ),

          //Title bar
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textBlack,
                decoration: todo.completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          //Button to send editTodo
          Container(
            margin: EdgeInsets.only(right:10),
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: ebYellow,
              borderRadius: BorderRadius.circular(5),
            ),
            child: GestureDetector(
              onTap: () {
                editTodoButton(context);
              },
              child: Center(
                child: Icon(Icons.settings, color:Colors.white, size:18,),
              )
            )
          ),

          //Button to send deleteTodo
          Container(
            margin: EdgeInsets.only(right:10),
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: deleteRed,
              borderRadius: BorderRadius.circular(5),
            ),
            child: GestureDetector(
              onTap: () async {
                await deleteFunction(context);
              },
              child: Center(
                child: Icon(Icons.delete, color:Colors.white, size:18,),
              )
            )
          ),
        ],    
      ),
    );
  }

  void editTodoButton(BuildContext context) {
      final titleController = TextEditingController(text: todo.title);
      final detailController = TextEditingController(text: todo.detail);
      final formKey = GlobalKey<FormState>();
    
      showDialog(
        context: context,
        builder: (context) {
          final navigator = Navigator.of(context);
    
          return AlertDialog(
            title: Text("Edit Todo"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Title"),
                    validator: (value) => value == null || value.trim().isEmpty ? "Title cannot be blank" : null,
                  ),
                  TextFormField(
                    controller: detailController,
                    decoration: InputDecoration(labelText: "Detail"),
                    validator: (value) => value == null || value.trim().isEmpty ? "Detail cannot be blank" : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => navigator.pop(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final updatedTodo = Todo(
                      id: todo.id,
                      title: titleController.text.trim(),
                      detail: detailController.text.trim(),
                      completed: todo.completed,
                    );
    
                    await Provider.of<TodoProvider>(context, listen: false).updateTodo(updatedTodo);
                    navigator.pop();
                  }
                },
                child: Text("Save"),
              )
            ],
          );
        },
      );
  }

  Future<void> deleteFunction(BuildContext context) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Todo"),
          content: Text("Are you sure you want to delete this todo?"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Delete")),
          ],
        ),
      );
    
      if (confirm == true) {
        await Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.id);
      }
  }
}