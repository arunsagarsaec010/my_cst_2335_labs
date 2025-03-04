import 'package:flutter/material.dart';
import 'package:my_cst_2335_labs/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true),
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
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  void _addItem() {
    if (_itemController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty) {
      setState(() {
        _items.add({
          'item': _itemController.text,
          'quantity': _quantityController.text,
        });
        _itemController.clear();
        _quantityController.clear();
      });
    }
  }

  // void initState(){
  //   super.initState();
  //
  //   $FloorAppDatabase.databaseBuilder("app_dtatbase.db").build().then((database){
  //     myDAO =  database.todoDao;
  //     myDAO.getAllItmes().then((listOfItems){
  //       setState(() {
  //       });
  //     });
  //    });
  // }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        decoration: const InputDecoration(
                          labelText: 'Type the item here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Type the quantity here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addItem,
                      child: const Text('Click here'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _items.isEmpty
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text('There are no items in the list')])
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${index + 1}: ${_items[index]['item']}: ${_items[index]['quantity']}',
                                  ),
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
                                            _deleteItem(index);
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
          )),
    );
  }
}
