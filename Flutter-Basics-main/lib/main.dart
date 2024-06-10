import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'pages/TodoModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late SharedPreferences _prefs;
  List<TodoModel> todos = [];

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  void _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTodoList();
  }

  void _loadTodoList() {
    List<String>? todoList = _prefs.getStringList('todos');
    if (todoList != null) {
      setState(() {
        todos = todoList
            .map((todo) => TodoModel.fromMap(jsonDecode(todo)))
            .toList();
      });
    }
  }

  void _saveTodoList() {
    List<String> todoList =
    todos.map((todo) => jsonEncode(todo.toMap())).toList();
    _prefs.setStringList('todos', todoList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(todos[index].title),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                todos.removeAt(index);
                _saveTodoList(); // Save the updated todo list
              });
            },
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todos[index].title),
                  SizedBox(height: 8), // Add spacing between the title and text field
                  TextField(
                    controller: TextEditingController(
                      text: todos[index].notes,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add notes...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      todos[index].notes = value; // Update the notes in the todo model
                      _saveTodoList(); // Save the updated todo list
                    },
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    todos.removeAt(index);
                    _saveTodoList(); // Save the updated todo list
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTodoItem(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTodoItem(BuildContext context) {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: 'Enter your todo'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    todos.add(TodoModel(title: textController.text));
                    _saveTodoList(); // Save the updated todo list
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
