import 'package:flutter/material.dart';
import 'package:unicorndial/unicorndial.dart';

class FloatingAddButton extends StatefulWidget {
  @override
  _FloatingAddButtonState createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<FloatingAddButton> {
  @override
  Widget build(BuildContext context) {
    var childrenButtons = List<UnicornButton>();

    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Expense',
      labelBackgroundColor: Colors.black,
      currentButton: FloatingActionButton(
          mini: true, onPressed: () => {}, child: Icon(Icons.train)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Bill',
      currentButton: FloatingActionButton(
          mini: true, onPressed: () => {debugPrint('hahhhh')}, child: Icon(Icons.directions_bike)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Income',
      currentButton: FloatingActionButton(
          mini: true, onPressed: () => {}, child: Icon(Icons.directions_bike)),
    ));

    return UnicornDialer(
      parentButton: Icon(Icons.add),
      finalButtonIcon: Icon(Icons.close),
      childButtons: childrenButtons,
    );
  }
}
