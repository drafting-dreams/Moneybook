import 'package:flutter/material.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:provider/provider.dart';

class MonthList extends StatelessWidget {
  final Function refresh;
  final List<Map<String, dynamic>> monthTransactionTotalList;

  Function onRefreshWrapper(String accountId) {
    Future<void> _onRefresh() async {
      if (monthTransactionTotalList.length > 0) {
        List<Map<String, dynamic>> previous =
            await TransactionAPI.loadPreviousYear(
                accountId, monthTransactionTotalList[0]['year']);
        refresh(previous);
      }
    }

    return _onRefresh;
  }

  MonthList(this.refresh, this.monthTransactionTotalList);

  build(BuildContext context) {
    var accountState = Provider.of<AccountState>(context);
    return RefreshIndicator(
        onRefresh: onRefreshWrapper(accountState.currentAccount.id),
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
                          style: totalAmount > 0
                              ? TextStyle(color: Colors.green[600])
                              : TextStyle(color: Colors.red[600]))
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
                      style: TextStyle(
                          color: e['amount'] > 0
                              ? Colors.green[600]
                              : Colors.red[600])),
                )
              ],
            );
          },
        ));
  }
}
