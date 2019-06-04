import 'package:flutter/material.dart';
import 'package:money_book/widget/floating_add_button.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/transaction.dart';

class BookScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookScreen();
  }
}

class _BookScreen extends State<BookScreen> {
//  RefreshController _refreshController;
  ScrollController _scrollController;

  Function _onRefreshWrapper(DateTime referenceDate, Transactions t) {
    debugPrint('reference' + referenceDate.toString());
    Future<void> _onRefresh() async {
      List<Transaction> previousTransactions =
          await TransactionAPI.loadPrevious(referenceDate);
      t.addBefore(previousTransactions);
      debugPrint('Refreshed');
    }

    return _onRefresh;
  }

  @override
  Widget build(BuildContext context) {
    int k = 0;
    var transactions = Provider.of<Transactions>(context);
    debugPrint('length' + transactions.length.toString());
    return Scaffold(
      appBar: AppBar(title: Text('MoneyBook')),
      floatingActionButton: FloatingAddButton(),
      body: RefreshIndicator(
        onRefresh: _onRefreshWrapper(
            transactions.previousLoadingReference, transactions),
        child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
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
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('History')),
        BottomNavigationBarItem(icon: Icon(Icons.equalizer), title: Text('Statistic'))
      ]),
    );
  }
}
