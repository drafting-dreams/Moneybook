import 'package:flutter/material.dart';
import 'package:money_book/widget/floating_add_button.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';

class BookScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookScreen();
  }
}

class _BookScreen extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Moneybook')),
      floatingActionButton: FloatingAddButton(),
      body: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (BuildContext context, int index) {
            final transaction = transactions.get(index);
            return ListTile(
              title: Text('${transaction.name}'),
              subtitle: Text('${transaction.value}'),
              trailing:
                  Text('${transaction.date.day}/${transaction.date.month}'),
            );
          }),
    );
  }
}
