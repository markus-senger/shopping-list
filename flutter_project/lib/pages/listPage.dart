import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../utils/shoppingListItem.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<Tuple3<String, Key, DateTime>> _shoppingList = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTextFieldVisible = false;
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
  bool _disconnected = false;

  @override
  void initState() {
    super.initState();
    _fetchShoppingList();
  }

  void saveList() async {
    var box = await Hive.openBox('shoppingList');
    await box.clear();
    await box.put(
      'items',
      _shoppingList.map((tuple) {
        return {
          'item1': tuple.item1.toString(),
          'item2': tuple.item2.toString(),
          'item3': tuple.item3.toString(),
        };
      }).toList(),
    );
  }

  Future<void> _fetchShoppingList() async {
    try {
      var event = (await _database.child('items').once());
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic>? items =
          dataSnapshot.value as Map<dynamic, dynamic>?;
      if (items != null) {
        _shoppingList.clear();
        items.forEach((key, value) {
          _shoppingList.add(Tuple3(value['name'], Key(value['guid']),
              _dateFormat.parse(value['dateTime'])));
        });
        _shoppingList.sort((a, b) => b.item3.compareTo(a.item3));
      } else {
        _shoppingList.clear();
        log('No data available');
      }
      saveList();
      _disconnected = false;
      setState(() {});
    } catch (error) {
      _shoppingList.clear();
      _disconnected = true;
      log('Error fetching shopping list: $error');
      setState(() {});
    }
  }

  Future<void> _uploadItem(String name) async {
    try {
      final String guid = const Uuid().v4();
      final String dateTime = _dateFormat.format(DateTime.now().toLocal());
      await _database.child("items").child(guid).set({
        'guid': guid,
        'name': name,
        'dateTime': dateTime,
      });
      _shoppingList
          .add(Tuple3(name, Key(guid), _dateFormat.parse(dateTime).toLocal()));
      _shoppingList.sort((a, b) => b.item3.compareTo(a.item3));
      _disconnected = false;
      saveList();
      //_fetchShoppingList();
      setState(() {});
    } catch (error) {
      _disconnected = true;
      log('Error upload item: $error');
      setState(() {});
    }
  }

  Future<void> _deleteItem(Key guid) async {
    try {
      final cleanedGuid = guid
          .toString()
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('\'', '');

      await _database.child("items").child(cleanedGuid).remove();
      _disconnected = false;
      saveList();
      //_fetchShoppingList();
      setState(() {});
    } catch (error) {
      _disconnected = true;
      log('Error deleting item: $error');
      setState(() {});
    }
  }

  Future<void> _updateItem(Key guid, String newName) async {
    try {
      final cleanedGuid = guid
          .toString()
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('\'', '');

      log(newName);
      await _database
          .child("items")
          .child(cleanedGuid)
          .update({'name': newName});

      int index = _shoppingList.indexWhere((item) => item.item2 == guid);
      if (index != -1) {
        _shoppingList[index] =
            Tuple3(newName, guid, _shoppingList[index].item3);
        _disconnected = false;
        saveList();
        //_fetchShoppingList();
        setState(() {});
      }
    } catch (error) {
      _disconnected = true;
      log('Error updating item: $error');
      setState(() {});
    }
  }

  void _toggleTextFieldVisibility() {
    setState(() {
      _isTextFieldVisible = !_isTextFieldVisible;
      if (!_isTextFieldVisible) {
        _textEditingController.clear();
      }
    });
  }

  void _addNewItem(String newItem) {
    if (newItem != "") {
      setState(() {
        _uploadItem(newItem);
        _textEditingController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
            alignment: Alignment.center,
            child: Visibility(
              visible: _disconnected,
              child: IconButton(
                padding: EdgeInsets.only(top: 150.0),
                icon: Icon(
                  Icons.wifi_off,
                  size: 90,
                  color: Colors.red,
                ),
                onPressed: () {},
              ),
            )),
        Expanded(
            child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 5.0,
                thumbColor: Theme.of(context).colorScheme.secondary,
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _shoppingList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: ShoppingListItem(
                          itemKey: _shoppingList[index].item2,
                          itemName: _shoppingList[index].item1,
                          dateTime: _dateFormat
                              .format(_shoppingList[index].item3.toLocal()),
                          onUpdated: _updateItem,
                          onDismissed: (uniqueKey) {
                            setState(() {
                              _shoppingList.removeWhere(
                                  (item) => item.item2 == uniqueKey);
                              _deleteItem(uniqueKey);
                            });
                          },
                        ),
                      );
                    }))),
        if (_isTextFieldVisible)
          TextField(
            autofocus: true,
            controller: _textEditingController,
            textAlignVertical: TextAlignVertical.center,
            autocorrect: false,
            enableSuggestions: false,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Neuen Eintrag hinzufügen',
              enabledBorder: InputBorder.none,
              suffixIcon: Padding(
                padding: EdgeInsets.only(bottom: 0.0),
                child: IconButton(
                  onPressed: () {
                    _addNewItem(_textEditingController.text);
                  },
                  icon: Icon(Icons.cloud_upload),
                  color: Colors.blueAccent,
                  iconSize: 36.0,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              hintStyle: TextStyle(color: Colors.black87),
            ),
          ),
      ]),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: (_isTextFieldVisible ? 50.0 : 0.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: true,
              child: FloatingActionButton(
                onPressed: () {
                  _fetchShoppingList();
                },
                tooltip: 'Einträge aktualisieren',
                child: Icon(Icons.refresh),
                backgroundColor: Colors.blue,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            SizedBox(width: 8.0), // Abstand zwischen den Buttons
            Visibility(
              visible: true,
              child: FloatingActionButton(
                onPressed: () {
                  _toggleTextFieldVisibility();
                },
                tooltip: 'Neuen Eintrag hinzufügen',
                child: Icon(_isTextFieldVisible ? Icons.close : Icons.add),
                backgroundColor: !_isTextFieldVisible
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
