import 'package:flutter/material.dart';
import 'package:money_book/widget/floating_add_button.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/widget/list/default_list.dart';
import 'package:money_book/widget/list/year_list.dart';

enum ActionTypes { byDay, byMonth, byYear }

class BookScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookScreen();
  }
}

class _BookScreen extends State<BookScreen> {
  ActionTypes _currentActionType = ActionTypes.byDay;
  List<Map<String, dynamic>> transactionByYear = [];

  void setActionType(ActionTypes type) {
    setState(() {
      _currentActionType = type;
      if (type == ActionTypes.byYear) {
        TransactionAPI.getListByYear().then((data) {
          setState(() {
            transactionByYear = data;
          });
        });
      }
    });
  }

  Function _onRefreshWrapper(DateTime referenceDate, Transactions t) {
    if (referenceDate == null) {
      return () {};
    }
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
    var transactions = Provider.of<Transactions>(context);

    Map<ActionTypes, Function> bodyWidgets = {
      ActionTypes.byDay: () => DefaultList(_onRefreshWrapper(
          transactions.previousLoadingReference, transactions)),
      ActionTypes.byYear: () {
        return YearList(transactionByYear);
      }
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
          child: ListView(
        children: <Widget>[
          RadioListTile<ActionTypes>(
            value: ActionTypes.byDay,
            title: Text('Default'),
            groupValue: _currentActionType,
            onChanged: setActionType,
          ),
          RadioListTile<ActionTypes>(
            value: ActionTypes.byMonth,
            title: Text('By Month'),
            groupValue: _currentActionType,
            onChanged: setActionType,
          ),
          RadioListTile<ActionTypes>(
            value: ActionTypes.byYear,
            title: Text('By Year'),
            groupValue: _currentActionType,
            onChanged: setActionType,
          ),
        ],
      )),
      floatingActionButton: FloatingAddButton(),
      body: bodyWidgets[_currentActionType](),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('History')),
        BottomNavigationBarItem(
            icon: Icon(Icons.equalizer), title: Text('Statistic'))
      ]),
    );
  }
}
