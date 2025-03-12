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
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Week9 Lab'),
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
  late TextEditingController _controller;
  late TextEditingController _qcontroller;
  late TodoDao myDAO;
  List<TodoItem> items = [];
  TodoItem? selectedItem;
  bool isDatabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _qcontroller = TextEditingController();
    initializeDatabase();
  }

  void initializeDatabase() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myDAO = database.todoDao;
    setState(() => isDatabaseInitialized = true);
    refreshItems();
  }

  Future<void> refreshItems() async {
    final list = await myDAO.getAllItems();
    setState(() => items = list);
  }

  @override
  void dispose() {
    _controller.dispose();
    _qcontroller.dispose();
    super.dispose();
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
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter item",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    controller: _qcontroller,
                    decoration: const InputDecoration(
                      hintText: "Quantity",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isDatabaseInitialized ? addItem : null,
                  child: const Text("Add"),
                ),
              ],
            ),
            Expanded(
              child: items.isEmpty
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text('There are no items in the list')],
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, rowNum) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Item: ${items[rowNum].todoItem}",
                                style: const TextStyle(fontSize: 30.0),
                              ),
                            ],
                          ),
                          subtitle: Text(
                              'Quantity: ${items[rowNum].quantity}\n ID: $rowNum'),
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
                                          selectedItem = items[rowNum];
                                          deleteItem(); // Calls the original deleteItem method
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
    );
  }

  void addItem() async {
    if (_controller.text.isEmpty || _qcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item')),
      );
      return;
    }

    final newItem =
        TodoItem(TodoItem.ID++, _controller.text, _qcontroller.text);
    await myDAO.insertItem(newItem);
    _controller.clear();
    _qcontroller.clear();
    refreshItems();
  }

  void deleteItem() async {
    if (selectedItem == null) return;

    await myDAO.deleteItem(selectedItem!);
    refreshItems();
    setState(() => selectedItem = null);
  }
}
