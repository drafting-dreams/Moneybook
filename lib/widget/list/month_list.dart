import 'package:flutter/material.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';

class MonthList extends StatelessWidget {
  final Function refresh;
  final List<Map<String, dynamic>> monthTransactionTotalList;

  Function onRefreshWrapper(String accountId, TransactionClass tc) {
    Future<void> _onRefresh() async {
      if (monthTransactionTotalList.length > 0) {
        List<Map<String, dynamic>> previous =
            await TransactionAPI.loadPreviousYear(
                accountId, monthTransactionTotalList[0]['year'], tc);
        refresh(previous);
      }
    }

    return _onRefresh;
  }

  MonthList(this.refresh, this.monthTransactionTotalList);

  TextStyle style(double total) {
    print(total);
    return total > 0
        ? TextStyle(color: Colors.green[600])
        : total < 0 ? TextStyle(color: Colors.red[600]) : null;
  }

  build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    var accountState = Provider.of<AccountState>(context);
    return RefreshIndicator(
        onRefresh:
            onRefreshWrapper(accountState.currentAccount.id, transactions.tc),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: monthTransactionTotalList.length,
          itemBuilder: (BuildContext context, int index) {
            final e = monthTransactionTotalList[index];
            final previous =
                index > 0 ? monthTransactionTotalList[index - 1] : null;
            Widget leading = Container(height: 0);
            String total = '';

            if (previous == null || previous['year'] != e['year']) {
              final totalAmount = monthTransactionTotalList
                  .where((item) => item['year'] == e['year'])
                  .fold(0.0, (current, next) => current + next['amount']);
              total = (totalAmount > 0 ? '+' : '') + totalAmount.toString();
              leading = Container(
                decoration: BoxDecoration(color: Colors.blue[100]),
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e['year'].toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(total,
                          textAlign: TextAlign.right,
                          style: style(totalAmount))
                    ]),
              );
            }

            return Column(
              children: <Widget>[
                leading,
                Divider(height: 2.0),
                ListTile(
                  title: Text(Util.getMonthName(e['month'])),
                  trailing: Text(
                      (e['amount'] > 0 ? '+' : '') + e['amount'].toString(),
                      style: style(e['amount'])),
                )
              ],
            );
          },
        ));
  }
}
