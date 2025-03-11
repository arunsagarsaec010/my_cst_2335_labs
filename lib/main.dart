import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:my_cst_2335_labs/todo_item.dart';
import 'database.dart';
import 'package:my_cst_2335_labs/todo_dao.dart';
import 'details_page.dart';
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
      home: const MyHomePage(title: 'Todo List'),
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
    final database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([
      Migration(1, 2, (database) async {
        await database.execute('DROP TABLE IF EXISTS TodoItem');
        await database.execute('''
          CREATE TABLE TodoItem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            todoItem TEXT NOT NULL,
            quantity TEXT NOT NULL
          )
        ''');
      }),
    ])
        .build();
    myDAO = database.todoDao;
    setState(() => isDatabaseInitialized = true); // Update the flag
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
    final bool isWideScreen = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWideScreen
            ? Row(
          children: [
            Expanded(child: buildListSection()),
            Expanded(child: buildDetailSection()),
          ],
        )
            : selectedItem == null
            ? buildListSection()
            : buildDetailSection(),
      ),
    );
  }

  Widget buildListSection() {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "New todo item",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: TextField(
                controller: _qcontroller, // Add the quantity controller
                decoration: const InputDecoration(
                  hintText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Set keyboard type to number
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
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index].todoItem),
              subtitle: Text('ID: ${items[index].id}, Quantity: ${items[index].quantity}'), // Display quantity
              onTap: () => setState(() => selectedItem = items[index]),
            ),
          ),
        ),
      ],

    );
  }

  Widget buildDetailSection() {
    return selectedItem == null
        ? const Center(child: Text('Select an item'))
        : DetailsPage(
      selectedItem: selectedItem!,
      deleteItem: deleteItem,
      closeDetails: () => setState(() => selectedItem = null),
    );
  }

  void addItem() async {
    if (_controller.text.isEmpty || _qcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item')),
      );
      return;
    }

    final newItem = TodoItem(TodoItem.ID++, _controller.text, _qcontroller.text);
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