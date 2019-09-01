// Flutter code sample for material.AppBar.actions.1

// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:money_book/screens/book_screen.dart';
import 'package:money_book/screens/income_edit_screen.dart';
import 'package:money_book/screens/expense_edit_screen.dart';
import 'package:money_book/screens/account_screen.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/model/account.dart';

void main() async {
  await DatabaseCreator().initDatabase();
  await AccountAPI.initializingAccount();
  await ExpenseTypeAPI.initializingTypes();
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatefulWidget {
  static const String _title = 'Moneybook';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AccountState accountState = AccountState();
  final Transactions transactions = Transactions();
  final ExpenseTypeInfo expenseTypes = ExpenseTypeInfo();

  @override
  void initState() {
    super.initState();
    Account currentAccount;
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(notifier: transactions),
        ChangeNotifierProvider.value(notifier: accountState),
        ChangeNotifierProvider.value(notifier: expenseTypes)
      ],
      child: MaterialApp(title: MyApp._title, routes: {
        '/': (context) => BookScreen(),
        '/edit/income': (context) => IncomeEditScreen(),
        '/edit/expense': (context) => ExpenseEditScreen(),
        '/accounts': (context) => AccountScreen()
      }),
    );
  }
}
