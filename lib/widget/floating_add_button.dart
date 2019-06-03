import 'package:flutter/material.dart';

//import 'package:unicorndial/unicorndial.dart';
import 'package:money_book/temp.dart';

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
      currentButton: FloatingActionButton(
          heroTag: 'expense',
          mini: true,
          onPressed: () => {Navigator.pushNamed(context, '/edit/expense')},
          child: Icon(Icons.train)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Bill',
      currentButton: FloatingActionButton(
          heroTag: 'bill',
          mini: true,
          onPressed: () => {debugPrint('hahhhh')},
          child: Icon(Icons.directions_bike)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Income',
      currentButton: FloatingActionButton(
          heroTag: 'income',
          mini: true,
          onPressed: () => {Navigator.pushNamed(context, '/edit/income')},
          child: Icon(Icons.directions_bike)),
    ));

    return UnicornDialer(
      parentButton: Icon(Icons.add),
      finalButtonIcon: Icon(Icons.close),
      childButtons: childrenButtons,
    );
  }
}
