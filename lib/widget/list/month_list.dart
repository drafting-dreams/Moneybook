import 'package:flutter/material.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';

class MonthList extends StatefulWidget {
  final Function refresh;
  final List<Map<String, dynamic>> monthTransactionTotalList;
  ScrollController scrollController;

  MonthList(this.refresh, this.monthTransactionTotalList, {this.scrollController});

  @override
  _MonthListState createState() => _MonthListState();
}

class _MonthListState extends State<MonthList> {
  final Set<int> hiddenYear = Set();

  Function onRefreshWrapper(String accountId, TransactionClass tc) {
    Future<void> _onRefresh() async {
      if (widget.monthTransactionTotalList.length > 0) {
        List<Map<String, dynamic>> previous =
            await TransactionAPI.getListByMonth(
                accountId, widget.monthTransactionTotalList[0]['year'] - 1, tc);
        widget.refresh(previous);
      }
    }

    return _onRefresh;
  }

  TextStyle style(double total) {
    return total > 0
        ? TextStyle(color: Colors.green[600])
        : total < 0 ? TextStyle(color: Colors.red[600]) : null;
  }

  build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    var transactions = Provider.of<Transactions>(context);
    var accountState = Provider.of<AccountState>(context);
    return RefreshIndicator(
        onRefresh:
            onRefreshWrapper(accountState.currentAccount.id, transactions.tc),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: this.widget.scrollController,
          itemCount: widget.monthTransactionTotalList.length,
          itemBuilder: (BuildContext context, int index) {
            final e = widget.monthTransactionTotalList[index];
            final previous =
                index > 0 ? widget.monthTransactionTotalList[index - 1] : null;
            Widget leading = Container(height: 0);
            String total = '';

            if (previous == null || previous['year'] != e['year']) {
              final totalAmount = widget.monthTransactionTotalList
                  .where((item) => item['year'] == e['year'])
                  .fold(0.0, (current, next) => current + next['amount']);
              total = (totalAmount > 0 ? '+' : '') + totalAmount.toStringAsFixed(2);
              leading = GestureDetector(
                  onTap: () {
                    setState(() {
                      if (hiddenYear.contains(e['year'])) {
                        hiddenYear.remove(e['year']);
                      } else {
                        hiddenYear.add(e['year']);
                      }
                    });
                  },
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).dividerColor),
                    padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e['year'].toString(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Container(),
                          ),
                          Text(total,
                              textAlign: TextAlign.right,
                              style: style(totalAmount)),
                          hiddenYear.contains(e['year'])
                              ? Icon(Icons.arrow_left)
                              : Icon(Icons.arrow_drop_down)
                        ]),
                  ));
            }

            return Column(
              children: <Widget>[
                leading,
                hiddenYear.contains(e['year'])
                    ? Container(
                        height: 0,
                      )
                    : Divider(height: 2.0),
                hiddenYear.contains(e['year'])
                    ? Container(
                        height: 0,
                      )
                    : ListTile(
                        title: Text(myLocale.languageCode.contains('zh')
                            ? Util.getMonthName(e['month'])['zh']
                            : Util.getMonthName(e['month'])['en']),
                        trailing: Text(
                            (e['amount'] > 0 ? '+' : '') +
                                e['amount'].toString(),
                            style: style(e['amount'])),
                      )
              ],
            );
          },
        ));
  }
}
