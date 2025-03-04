import 'package:flutter/material.dart';
import 'package:my_cst_2335_labs/todo_item.dart';

import 'database.dart';
import 'package:my_cst_2335_labs/todo_dao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  late TextEditingController _controller; //late - Constructor in initState()
  late TodoDao myDAO; //initialized in initState()

  //add items from the database first:
  List<TodoItem> items = [];

  var isChecked = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override //same as in java
  void initState() {
    super.initState(); //call the parent initState()
    _controller = TextEditingController(); //our late constructor
    //var database = await
    //open the database:
    $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build()
        .then((database) {
      myDAO = database.todoDao;
      //get Items from database:
      myDAO.getAllItems().then((listOfItems) {
        setState(() {
          items.clear();
          items.addAll(listOfItems); //Future<> , asnynchronous
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // clean up memory
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [

                Flexible(
                    child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Type something here",
                    labelText: "Enter a todo item",
                    border: OutlineInputBorder(),
                  ),
                )),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.value.text.isNotEmpty) {
                      setState(() {
                        var newItem =
                            TodoItem(TodoItem.ID++, _controller.value.text);
                        myDAO.insertItem(newItem);
                        items.add(newItem);
                        _controller.text = "";
                      });
                    } else {
                      var snackBar = const SnackBar(
                          content: Text("Input field is required!!"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }, //Lambda, or anonymous function
                  child: Text("Add"),
                )
              ],
            ),
            Expanded(
              child: items.isEmpty
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text('There are no items in the list')])
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, rowNum) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Item $rowNum = ${items[rowNum].todoItem}",
                                  style: TextStyle(fontSize: 30.0)),
                            ],
                          ),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Item'),
                                  content: const Text(
                                      'Are you sure you want to delete this item?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          myDAO.deleteItem(items[rowNum]);
                                          items.removeAt(rowNum);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
