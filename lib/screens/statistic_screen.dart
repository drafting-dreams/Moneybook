import 'package:flutter/material.dart';
import 'package:money_book/widget/statistic/pie_chart.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';

enum Mode { year, month, seven, thirty }

class StatisticScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatisticScreen();
  }
}

class _StatisticScreen extends State<StatisticScreen> {
  Mode currentMode = Mode.seven;
  int year;
  int month;
  String accountId;
  Map<String, double> pieChartData;

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
    DateTime today = DateTime.now();
    switch (currentMode) {
      case Mode.seven:
        DateTime sixDaysAgo = today.subtract(Duration(days: 6));
        TransactionAPI.getSumByTypeGroupSpecific(accountId, sixDaysAgo, today)
            .then((json) {
          setState(() {
            pieChartData = json;
          });
        });
        break;
      case Mode.thirty:
        DateTime twentyNineDaysAgo = today.subtract(Duration(days: 29));
        TransactionAPI.getSumByTypeGroupSpecific(
                accountId, twentyNineDaysAgo, today)
            .then((json) {
          setState(() {
            pieChartData = json;
          });
        });
        break;
      case Mode.month:
      case Mode.year:
        TransactionAPI.getSumByTypeGroup(
                accountId, year, currentMode == Mode.month ? month : null)
            .then((json) {
          this.setState(() {
            this.pieChartData = json;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    double pieTotal = 0;
    if (pieChartData != null) {
      pieChartData.forEach((_, v) {
        pieTotal += v;
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Statistic'),
          actions: <Widget>[
            PopupMenuButton(
                icon: Icon(Icons.menu),
                initialValue: currentMode,
                onSelected: (Mode mode) {
                  setState(() {
                    currentMode = mode;
                    loadData();
                  });
                },
                itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<Mode>(
                          value: Mode.seven, child: Text('recent 7 days')),
                      const PopupMenuItem<Mode>(
                          value: Mode.thirty, child: Text('recent 30 days')),
                      const PopupMenuItem<Mode>(
                          value: Mode.month, child: Text('by month')),
                      const PopupMenuItem<Mode>(
                          value: Mode.year, child: Text('by year')),
                    ])
          ],
        ),
        bottomNavigationBar: BottomNavigator(
          initialIndex: 1,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            pieChartData != null
                ? SizedBox(
                    height: 300,
                    child: Stack(children: [
                      Positioned(top: 50, left: 263, child: Text('Total   ${-pieTotal}')),
                      PieOutsideLabelChart(
                        pieChartData,
                        animate: true,
                      ),
                    ]),
                  )
                : Container()
          ],
        ));
  }
}
