import 'package:flutter/material.dart';

//import 'package:unicorndial/unicorndial.dart';
import 'package:money_book/temp.dart';
import 'package:money_book/screens/income_edit_screen.dart';
import 'package:money_book/screens/expense_edit_screen.dart';

class FloatingAddButton extends StatefulWidget {
  Function update;

  FloatingAddButton({this.update});

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
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ExpenseEditScreen(update: this.widget.update)));
          },
          child: Icon(Icons.train)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Bill',
      currentButton: FloatingActionButton(
          heroTag: 'bill',
          mini: true,
          onPressed: () {
            debugPrint('hahhhh');
          },
          child: Icon(Icons.directions_bike)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: 'Income',
      currentButton: FloatingActionButton(
          heroTag: 'income',
          mini: true,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => IncomeEditScreen(
                          update: this.widget.update,
                        )));
          },
          child: Icon(Icons.directions_bike)),
    ));

    return UnicornDialer(
      parentButton: Icon(Icons.add),
      finalButtonIcon: Icon(Icons.close),
      childButtons: childrenButtons,
    );
  }
}
