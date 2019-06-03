// Flutter code sample for material.AppBar.actions.1

// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:money_book/screens/book_screen.dart';
import 'package:money_book/screens/income_edit_screen.dart';
import 'package:money_book/screens/expense_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/api/transaction.dart';

void main() async {
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatefulWidget {
  static const String _title = 'Moneybook';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Transactions transactions = Transactions();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final nextMonth = now.month == 12
        ? DateTime(now.year + 1, now.month, 1)
        : DateTime(now.year, now.month + 1, 1);
    TransactionAPI.loadPrevious(nextMonth).then((List<Transaction> ts) {
      setState(() {
        this.transactions.addAll(ts);
        this
            .transactions
            .add(new Transaction(2000, DateTime.now(), name: 'Income'));
        this
            .transactions
            .add(new Transaction(3000, DateTime.now(), name: 'Income'));
        this
            .transactions
            .add(new Transaction(4000, DateTime.now(), name: 'Income'));
      });
      debugPrint(this.transactions.get(0).id.toString());
      debugPrint(this.transactions.get(1).id.toString());
      debugPrint(this.transactions.get(2).id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(notifier: transactions)],
      child: MaterialApp(title: MyApp._title, routes: {
        '/': (context) => BookScreen(),
        '/edit/income': (context) => IncomeEditScreen(),
        '/edit/expense': (context) => ExpenseEditScreen(),
      }),
    );
  }
}
