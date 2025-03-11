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
  late TodoDao myDAO;
  List<TodoItem> items = [];
  TodoItem? selectedItem;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    initializeDatabase();
  }

  void initializeDatabase() async {
    final database =
    await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myDAO = database.todoDao;
    refreshItems();
  }

  Future<void> refreshItems() async {
    final list = await myDAO.getAllItems();
    setState(() => items = list);
  }

  @override
  void dispose() {
    _controller.dispose();
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
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add"),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index].todoItem),
              subtitle: Text('ID: ${items[index].id}'),
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
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item')),
      );
      return;
    }

    final newItem = TodoItem(TodoItem.ID++, _controller.text);
    await myDAO.insertItem(newItem);
    _controller.clear();
    refreshItems();
  }

  void deleteItem() async {
    if (selectedItem == null) return;

    await myDAO.deleteItem(selectedItem!);
    refreshItems();
    setState(() => selectedItem = null);
  }
}