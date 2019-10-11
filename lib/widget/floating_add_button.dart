import 'package:flutter/material.dart';

import 'package:unicorndial/unicorndial.dart';
import 'package:money_book/screens/income_edit_screen.dart';
import 'package:money_book/screens/expense_edit_screen.dart';
import 'package:money_book/locale/locales.dart';

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
    var localizer = AppLocalizations.of(context);

    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: localizer.expense,
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
          child: Icon(Icons.credit_card)),
    ));
    childrenButtons.add(UnicornButton(
      hasLabel: true,
      labelText: localizer.income,
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
          child: Icon(Icons.monetization_on)),
    ));

    return UnicornDialer(
      parentButton: Icon(Icons.add),
      finalButtonIcon: Icon(Icons.close),
      childButtons: childrenButtons,
    );
  }
}
