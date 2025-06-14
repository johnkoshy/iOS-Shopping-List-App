import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(ShoppingListApp());
}

class ShoppingListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Shopping List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ShoppingListPage(),
    );
  }
}

class ShoppingListPage extends StatefulWidget {
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    _prefs = await SharedPreferences.getInstance();
    final String? itemsJson = _prefs.getString('shopping_list');
    if (itemsJson != null) {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      setState(() {
        _items.addAll(decoded.map((item) => Map<String, dynamic>.from(item)));
      });
    }
  }

  Future<void> _saveItems() async {
    final String itemsJson = jsonEncode(_items);
    await _prefs.setString('shopping_list', itemsJson);
  }

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _items.add({'name': _controller.text, 'bought': false});
        _controller.clear();
        _saveItems();
      });
    }
  }

  void _toggleBought(int index) {
    setState(() {
      _items[index]['bought'] = !_items[index]['bought'];
      _saveItems();
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      _saveItems();
    });
  }

  void _editItem(int index) {
    TextEditingController editController =
    TextEditingController(text: _items[index]['name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: 'Enter new item name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    _items[index]['name'] = editController.text;
                    _saveItems();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('iOS Shopping List')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter item (e.g., Apples)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: _items[index]['bought'],
                    onChanged: (value) => _toggleBought(index),
                  ),
                  title: Text(
                    _items[index]['name'],
                    style: TextStyle(
                      decoration: _items[index]['bought']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  onTap: () => _editItem(index), // Tap to edit
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}