import 'package:flutter/material.dart';
import 'package:money_book/widget/floating_add_button.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/widget/list/default_list.dart';
import 'package:money_book/widget/list/month_list.dart';
import 'package:money_book/widget/list/year_list.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/widget/expanded_section.dart';
import 'package:money_book/utils/util.dart';

enum ActionTypes { byDay, byMonth, byYear, customize }

class BookScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookScreen();
  }
}

class _BookScreen extends State<BookScreen> {
  ActionTypes _currentActionType = ActionTypes.byDay;
  List<Map<String, dynamic>> transactionByYear = [];
  List<Map<String, dynamic>> transactionByMonth = [];
  int startYear = DateTime.now().year;
  int endYear = DateTime.now().year;
  int startMonth = 1;
  int endMonth = 12;
  bool expand = false;

  Function setActionTypeWrapper(String accountId, TransactionClass tc) {
    void setActionType(ActionTypes type) {
      setState(() {
        _currentActionType = type;
        switch (type) {
          case ActionTypes.byDay:
            setState(() {
              expand = false;
            });
            break;
          case ActionTypes.byMonth:
            TransactionAPI.getListByMonth(accountId, DateTime.now().year, tc)
                .then((data) {
              setState(() {
                transactionByMonth = data;
                expand = false;
              });
            });
            break;
          case ActionTypes.byYear:
            TransactionAPI.getListByYear(accountId, tc).then((data) {
              setState(() {
                transactionByYear = data;
                expand = false;
              });
            });
            break;
          case ActionTypes.customize:
            setState(() {
              expand = true;
            });
        }
      });
    }

    return setActionType;
  }

  Function setClassWrapper(String accountId, Transactions ts) {
    void setClass(TransactionClass transactionClass) {
      ts.setClass(transactionClass);
      switch (_currentActionType) {
        case ActionTypes.byDay:
          break;
        case ActionTypes.byMonth:
          TransactionAPI.getListByMonth(accountId, DateTime.now().year, ts.tc)
              .then((data) {
            setState(() {
              transactionByMonth = data;
            });
          });
          break;
        case ActionTypes.byYear:
          TransactionAPI.getListByYear(accountId, ts.tc).then((data) {
            setState(() {
              transactionByYear = data;
            });
          });
          break;
        case ActionTypes.customize:
      }
    }

    return setClass;
  }

  Function _onRefreshWrapper(
      String accountId, DateTime referenceDate, Transactions t) {
    if (referenceDate == null) {
      Future<void> doNothing() async {}
      return doNothing;
    }
    Future<void> _onRefresh() async {
      List<Transaction> previousTransactions =
          await TransactionAPI.loadPrevious(accountId, referenceDate);
      t.addBefore(previousTransactions);
    }

    return _onRefresh;
  }

  void refreshTransactionByMonth(previous) {
    setState(() {
      transactionByMonth.insertAll(0, previous);
    });
  }

//  Function _monthFreshWrapper(
//      int year, List<Map<String, dynamic>> monthTransactionTotalList) {
//    Future<void> _onRefresh() async {
//      List<Map<String, dynamic>> previous = await TransactionAPI.loadPreviousYear(year);
//      setState(() {
//        monthTransactionTotalList.insertAll(0, previous);
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    var accountState = Provider.of<AccountState>(context);

    final String currentAccountId = accountState.currentAccount == null
        ? ''
        : accountState.currentAccount.id;

    Map<ActionTypes, Function> bodyWidgets = {
      ActionTypes.byDay: () => DefaultList(_onRefreshWrapper(currentAccountId,
          transactions.previousLoadingReference, transactions)),
      ActionTypes.byYear: () => YearList(transactionByYear),
      ActionTypes.byMonth: () =>
          MonthList(refreshTransactionByMonth, transactionByMonth),
      ActionTypes.customize: () => DefaultList(_onRefreshWrapper(
          currentAccountId,
          transactions.previousLoadingReference,
          transactions))
    };

    return Scaffold(
        appBar: AppBar(
          title: Text('MoneyBook'),
          actions: <Widget>[
            Builder(
              builder: (innerContext) => IconButton(
                    icon: Icon(Icons.tune),
                    onPressed: () => Scaffold.of(innerContext).openEndDrawer(),
                  ),
            )
          ],
        ),
        endDrawer: Drawer(
            child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 26.0, vertical: 10.0),
                child: Text(
                  'Class',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            RadioListTile<TransactionClass>(
              value: TransactionClass.all,
              title: Text('All'),
              groupValue: transactions.tc,
              onChanged: setClassWrapper(currentAccountId, transactions),
            ),
            RadioListTile<TransactionClass>(
              value: TransactionClass.income,
              title: Text('Income'),
              groupValue: transactions.tc,
              onChanged: setClassWrapper(currentAccountId, transactions),
            ),
            RadioListTile<TransactionClass>(
              value: TransactionClass.expense,
              title: Text('Expense'),
              groupValue: transactions.tc,
              onChanged: setClassWrapper(currentAccountId, transactions),
            ),
            Divider(height: 2.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 26.0, vertical: 10.0),
                child: Text('Time',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              ),
            ),
            RadioListTile<ActionTypes>(
              value: ActionTypes.byDay,
              title: Text('Default'),
              groupValue: _currentActionType,
              onChanged:
                  setActionTypeWrapper(currentAccountId, transactions.tc),
            ),
            RadioListTile<ActionTypes>(
              value: ActionTypes.byMonth,
              title: Text('By Month'),
              groupValue: _currentActionType,
              onChanged:
                  setActionTypeWrapper(currentAccountId, transactions.tc),
            ),
            RadioListTile<ActionTypes>(
              value: ActionTypes.byYear,
              title: Text('By Year'),
              groupValue: _currentActionType,
              onChanged:
                  setActionTypeWrapper(currentAccountId, transactions.tc),
            ),
            RadioListTile<ActionTypes>(
                value: ActionTypes.customize,
                title: Text('Customize'),
                groupValue: _currentActionType,
                onChanged:
                    setActionTypeWrapper(currentAccountId, transactions.tc)),
            ExpandedSection(
                expand: expand,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(width: 50, margin: EdgeInsets.only(left: 26), child: Text('From ')),
                        DropdownButton<int>(
                            value: startYear,
                            onChanged: (int i) {
                              setState(() {
                                startYear = i;
                              });
                            },
                            items: <int>[
                              for (var i = 2019;
                                  i <= DateTime.now().year;
                                  i += 1)
                                i
                            ]
                                .map<DropdownMenuItem<int>>((int value) =>
                                    DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString())))
                                .toList()),
                        Container(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('-')),
                        DropdownButton<int>(
                            value: startMonth,
                            onChanged: (int i) {},
                            items: <int>[for (var i = 1; i <= 12; i += 1) i]
                                .map<DropdownMenuItem<int>>((int value) =>
                                    DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(Util.getMonthName(value))))
                                .toList()),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(width: 50, margin: EdgeInsets.only(left: 26), child: Text(' to ')),
                        DropdownButton<int>(
                            value: endYear,
                            onChanged: (int i) {},
                            items: <int>[
                              for (var i = 2019;
                                  i <= DateTime.now().year;
                                  i += 1)
                                i
                            ]
                                .map<DropdownMenuItem<int>>((int value) =>
                                    DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString())))
                                .toList()),
                        Container(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('-')),
                        DropdownButton<int>(
                            value: endMonth,
                            onChanged: (int i) {},
                            items: <int>[for (var i = 1; i <= 12; i += 1) i]
                                .map<DropdownMenuItem<int>>((int value) =>
                                    DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(Util.getMonthName(value))))
                                .toList()),
                      ],
                    )
                  ],
                ))
          ],
        )),
        floatingActionButton: FloatingAddButton(),
        body: bodyWidgets[_currentActionType](),
        bottomNavigationBar: BottomNavigator(initialIndex: 0));
  }
}
