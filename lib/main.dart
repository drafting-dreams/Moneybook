// Flutter code sample for material.AppBar.actions.1

// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:money_book/screens/book_screen.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/model/transaction.dart';

void main() => runApp(MyApp());

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
    // TODO: implement initState
    super.initState();
    setState(() {
      this.transactions.add(new Transaction(2000, 'Income'));
      this.transactions.add(new Transaction(3000, 'Income'));
      this.transactions.add(new Transaction(4000, 'Income'));
    });
    debugPrint(this.transactions.get(0).id.toString());
    debugPrint(this.transactions.get(1).id.toString());
    debugPrint(this.transactions.get(2).id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(notifier: transactions)],
      child: MaterialApp(title: MyApp._title, routes: {
        '/': (context) => BookScreen(),
      }),
    );
  }
}
