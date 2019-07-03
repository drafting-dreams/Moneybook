import 'package:flutter/material.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';

class DefaultList extends StatelessWidget {
  final Function onRefresh;

  DefaultList(this.onRefresh);

  build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    return RefreshIndicator(
//      onRefresh: _onRefreshWrapper(
//        transactions.previousLoadingReference, transactions),
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          final transaction = transactions.get(index);
          final previous = index > 0 ? transactions.get(index - 1) : null;
          Widget leading = Container(height: 0);
          String total = '';

          if (previous == null ||
            transaction.date.year != previous.date.year ||
            transaction.date.month != previous.date.month) {
            final totalAmount =
            transactions.getTotalOfMonth(transaction.date);
            total = (totalAmount > 0 ? '+' : '') + totalAmount.toString();
            leading = Container(
              decoration: BoxDecoration(color: Colors.blue[100]),
              padding:
              EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${transaction.date.year}/${transaction.date.month}',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(total,
                    textAlign: TextAlign.right,
                    style: totalAmount > 0
                      ? TextStyle(color: Colors.green[600])
                      : TextStyle(color: Colors.red[600]))
                ]),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              leading,
              Divider(
                height: 2.0,
              ),
              ListTile(
                title: Text('${transaction.name}'),
                subtitle: Text(
                  (transaction.value > 0 ? '+' : '') +
                    '${transaction.value}',
                  style: transaction.value > 0
                    ? TextStyle(color: Colors.green[600])
                    : TextStyle(color: Colors.red[600]),
                ),
                trailing: Text(
                  '${transaction.date.day}/${transaction.date.month}'),
              ),
            ],
          );
        }),
    );
  }
}