import 'package:flutter/material.dart';
import 'package:money_book/widget/statistic/pie_chart.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/utils/util.dart';

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
    setState(() {
      year = now.year;
      month = now.month;
    });

    AccountAPI.getCurrentAccount().then((account) {
      setState(() {
        accountId = account.id;
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
                    height: 400,
                    child: Stack(children: [
                      currentMode == Mode.year || currentMode == Mode.month
                          ? Positioned(
                              top: 5,
                              left: 20,
                              child: DropdownButton(
                                  value: this.year,
                                  items: <int>[
                                    for (var i = 2019;
                                        i <= DateTime.now().year;
                                        i += 1)
                                      i
                                  ]
                                      .map((int value) => DropdownMenuItem(
                                          value: value, child: Text('$value')))
                                      .toList(),
                                  onChanged: (int i) {
                                    if (i == this.year) {
                                      return;
                                    }
                                    setState(() {
                                      this.year = i;
                                      loadData();
                                    });
                                  }),
                            )
                          : Container(),
                      currentMode == Mode.month
                          ? Positioned(
                              top: 5,
                              left: 100,
                              child: DropdownButton(
                                  value: this.month,
                                  items: <int>[
                                    for (var i = 1; i <= 12; i += 1) i
                                  ]
                                      .map<DropdownMenuItem<int>>((int value) =>
                                          DropdownMenuItem<int>(
                                              value: value,
                                              child: Text(
                                                  Util.getMonthName(value))))
                                      .toList(),
                                  onChanged: (int i) {
                                    if (i == this.month) {
                                      return;
                                    }
                                    setState(() {
                                      this.month = i;
                                      loadData();
                                    });
                                  }))
                          : Container(),
                      Positioned(
                          top: 20,
                          right: 20,
                          child: pieChartData.isEmpty ? Container() : Text(
                            'Total   ${-pieTotal}',
                            style: Theme.of(context).textTheme.title,
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        child: PieOutsideLabelChart(
                          pieChartData,
                          animate: true,
                        ),
                      ),
                    ]),
                  )
                : Container()
          ],
        ));
  }
}
