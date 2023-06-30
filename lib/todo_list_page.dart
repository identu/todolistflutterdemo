import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'todo.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    List<Map<String, dynamic>> todoListData = await DbHelper.instance.queryAll();
    setState(() {
      _todos = todoListData.map((json) => Todo.fromJson(json)).toList();
    });
  }

  Future<void> _addTodo() async {
    String todoTitle = _textEditingController.text.trim();
    if (todoTitle.isNotEmpty) {
      Todo newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch,
        title: todoTitle,
        completed: false,
      );

      await DbHelper.instance.insert(newTodo.toJson());

      setState(() {
        _todos.add(newTodo);
      });

      _textEditingController.clear();
    }
  }

  Future<void> _toggleTodoStatus(int todoId, bool completed) async {
    Todo todoToUpdate = _todos.firstWhere((todo) => todo.id == todoId);
    Todo updatedTodo = Todo(
      id: todoToUpdate.id,
      title: todoToUpdate.title,
      completed: completed,
    );

    await DbHelper.instance.update(updatedTodo.id, updatedTodo.toJson());

    setState(() {
      todoToUpdate.completed = completed;
    });
  }

  Future<void> _deleteTodo(int todoId) async {
    await DbHelper.instance.delete(todoId);

    setState(() {
      _todos.removeWhere((todo) => todo.id == todoId);
    });
  }

  Widget _buildTodoItem(Todo todo) {
    return ListTile(
      leading: Checkbox(
        value: todo.completed,
        onChanged: (completed) {
          _toggleTodoStatus(todo.id, completed!);
        },
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _deleteTodo(todo.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return _buildTodoItem(_todos[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Todo'),
                content: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(hintText: 'Todo Title'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addTodo();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

}
