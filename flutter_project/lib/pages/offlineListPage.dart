import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class OfflineListPage extends StatefulWidget {
  const OfflineListPage({super.key});

  @override
  State<OfflineListPage> createState() => _OfflineListState();
}

class _OfflineListState extends State<OfflineListPage> {
  final List<Tuple3<String, String, DateTime>> _shoppingList = [];
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    loadList();
  }

  void loadList() async {
    var box = await Hive.openBox('shoppingList');
    _shoppingList.clear();
    _shoppingList.addAll(
        (box.get('items', defaultValue: []) as List<dynamic>).map((item) {
      var map = item as Map<dynamic, dynamic>;
      return Tuple3<String, String, DateTime>(map['item1'] as String,
          map['item2'] as String, DateTime.parse(map['item3']));
    }));
    log(_shoppingList.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: ListView.builder(
        itemCount: _shoppingList.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(0.0),
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            child: Column(
              children: [
                Text(
                  _dateFormat.format(_shoppingList[index].item3),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                ListTile(
                  title: Text(_shoppingList[index].item1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
