// details_page.dart
import 'package:flutter/material.dart';
import 'todo_item.dart';

class DetailsPage extends StatelessWidget {
  final TodoItem selectedItem;
  final Function deleteItem;
  final Function closeDetails;

  const DetailsPage({
    super.key,
    required this.selectedItem,
    required this.deleteItem,
    required this.closeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DetailRow('Name:', selectedItem.todoItem),
            DetailRow('Quantity', selectedItem.quantity),
            DetailRow('ID:', selectedItem.id.toString()),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => deleteItem(),
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () => closeDetails(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
