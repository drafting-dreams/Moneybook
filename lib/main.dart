// Flutter code sample for material.AppBar.actions.1

// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:money_book/api/bill.dart';
import 'app.dart' as app;
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/shared_state/theme.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/model/account.dart';
import 'const/themes.dart';

void main() async {
  await DatabaseCreator().initDatabase();
  await AccountAPI.initializingAccount();
  await ExpenseTypeAPI.initializingTypes();
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AccountState accountState = AccountState();
  final Transactions transactions = Transactions();
  final ExpenseTypeInfo expenseTypes = ExpenseTypeInfo();
  final ThemeChanger themeChanger = ThemeChanger(getTheme('noble purple'));
  bool popup = false;

  Future _showDialog() => showDialog(
      context: app.navigatorKey.currentState.overlay.context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
            title: Text('Autopay notification'),
            content: Text('Autopay bills has been paid.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Got it'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ));

  Future checkAndPay() {
    return BillAPI.getPreviousUnpaidBills().then((unpaidBills) {
      if (unpaidBills.length > 0) {
        for (var b in unpaidBills) {
          Transaction t = Transaction(b.value, b.dueDate, b.accountId,
              type: b.type, name: b.name);
          BillAPI.pay(b.id, t);
          transactions.add(t);
        }
        setState(() {
          popup = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Account currentAccount;
    ExpenseTypeAPI.list().then((types) {
      expenseTypes.addAll(types);
    });
    AccountAPI.getCurrentAccount().then((Account account) {
      currentAccount = account;
      accountState.setCurrentAccount(currentAccount);
      final now = DateTime.now();
      final nextMonth = now.month == 12
          ? DateTime(now.year + 1, now.month, 1)
          : DateTime(now.year, now.month + 1, 1);
      TransactionAPI.loadPrevious(accountState.currentAccount.id, nextMonth)
          .then((List<Transaction> ts) {
        setState(() {
          transactions.clear();
          transactions.addAll(ts);
        });
      });
    });
    WidgetsBinding.instance.addObserver(this);
    checkAndPay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await checkAndPay();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (popup) {
      _showDialog().then((_) {
        setState(() {
          popup = false;
        });
      });
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(notifier: transactions),
        ChangeNotifierProvider.value(notifier: accountState),
        ChangeNotifierProvider.value(notifier: expenseTypes),
        ChangeNotifierProvider.value(notifier: themeChanger)
      ],
      child: app.App(),
    );
  }
}
