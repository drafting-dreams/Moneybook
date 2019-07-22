import 'package:flutter/material.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';

enum Mode { year, month }

class StatisticScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatisticScreen();
  }
}

class _StatisticScreen extends State<StatisticScreen> {
  Mode currentMode = Mode.month;
  int year;
  int month;
  String accountId;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    AccountAPI.getCurrentAccount().then((account) {
      setState(() {
        accountId = account.id;
        year = now.year;
        month = now.month;
        loadData();
      });
    });
  }

  loadData() {
    TransactionAPI.getSumByTypeGroup(
            accountId, year, currentMode == Mode.month ? month : null)
        .then((json) {
      print(json);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistic')),
      bottomNavigationBar: BottomNavigator(
        initialIndex: 1,
      ),
    );
  }
}
