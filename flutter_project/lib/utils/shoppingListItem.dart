import 'dart:developer';

import 'package:flutter/material.dart';

class ShoppingListItem extends StatefulWidget {
  final String itemName;
  final String dateTime;
  final void Function(Key) onDismissed;
  final void Function(Key, String) onUpdated;
  final Key itemKey;

  const ShoppingListItem(
      {Key? key,
      required this.itemName,
      required this.dateTime,
      required this.onDismissed,
      required this.itemKey,
      required this.onUpdated})
      : super(key: key);

  @override
  _ShoppingListItemState createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  late String _currentItemName;
  late String _dateTime;
  late void Function(Key) _onDismissed;
  late void Function(Key, String) _onUpdated;
  bool _isTextFieldVisible = false;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _currentItemName = widget.itemName;
    _dateTime = widget.dateTime;
    _onDismissed = widget.onDismissed;
    _onUpdated = widget.onUpdated;
    _textEditingController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ShoppingListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemName != _currentItemName) {
      setState(() {
        _currentItemName = widget.itemName;
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.itemKey,
      onDismissed: (_) => _onDismissed(widget.itemKey),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0.0),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
        child: Column(
          children: [
            Text(
              _dateTime,
              style: TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                Expanded(
                  child: _isTextFieldVisible
                      ? TextField(
                          controller: _textEditingController,
                          onSubmitted: (value) {
                            setState(() {
                              _currentItemName = value;
                              _isTextFieldVisible = false;
                            });
                            _onUpdated(widget.itemKey, _currentItemName);
                          },
                        )
                      : Text(
                          _currentItemName,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isTextFieldVisible = !_isTextFieldVisible;
                      if (_isTextFieldVisible) {
                        _textEditingController.text = _currentItemName;
                      }
                    });
                  },
                  icon: Icon(Icons.edit),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
