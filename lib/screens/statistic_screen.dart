import 'package:flutter/material.dart';
import 'package:money_book/widget/statistic/pie_chart.dart';
import 'package:money_book/widget/statistic/line_chart.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/widget/multi_select_chip.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/utils/util.dart';

enum Mode { year, month, seven, thirty, six_month }

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
  DateTime start;
  DateTime end;
  String accountId;
  Map<String, double> pieChartData;
  List<Map<String, double>> lineChartData = [];
  List<String> typeList;
  List<String> selectedTypes;
  final key = GlobalKey<MultiSelectChipState>();

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
        setState(() {
          start = sixDaysAgo;
          end = today;
          loadByDate();
        });
        break;
      case Mode.thirty:
        DateTime twentyNineDaysAgo = today.subtract(Duration(days: 29));
        setState(() {
          start = twentyNineDaysAgo;
          end = today;
          loadByDate();
        });
        break;
      case Mode.six_month:
        DateTime _start, _end;
        if (today.month <= 6) {
          _start = DateTime(today.year - 1, 12 + (today.month - 6), 1);
        } else {
          _start = DateTime(today.year, today.month - 6, 1);
        }
        _end = DateTime(today.year, today.month, 0);
        setState(() {
          start = _start;
          end = _end;
          loadByDate();
        });
        break;
      case Mode.month:
      case Mode.year:
        loadByGroup();
    }
  }

  void loadByDate() {
    TransactionAPI.getSumByTypeGroupSpecific(accountId, start, end)
        .then((json) {
      setState(() {
        pieChartData = json;
      });
    });
  }

  void loadByGroup() {
    TransactionAPI.getSumByTypeGroup(
            accountId, year, currentMode == Mode.month ? month : null)
        .then((json) {
      setState(() {
        this.pieChartData = json;
      });
    });
    if (currentMode == Mode.month) {
      var futures = <Future<Map<String, double>>>[];
      for (int i = 1; i <= 12; i++) {
        futures.add(TransactionAPI.getSumByTypeGroup(accountId, year, i));
      }
      Future.wait(futures).then((List<Map<String, double>> data) {
        final List<String> typeList = [];
        data.forEach((map) {
          map.forEach((key, value) {
            if (!typeList.contains(key)) {
              typeList.add(key);
            }
          });
        });
        setState(() {
          this.typeList = typeList;
          this.selectedTypes = typeList;
          this.lineChartData = data;
        });
      });
    }
  }

  _showSelectDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Select Transaction Types'),
              content: MultiSelectChip(this.typeList,
                  initialList: this.selectedTypes, key: this.key),
              actions: <Widget>[
                FlatButton(
                  child: Text('Select'),
                  onPressed: () {
                    setState(() {
                      this.selectedTypes = this.key.currentState.selectedChoice;
                    });
                    Navigator.of(context).pop();
                  },
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    double pieTotal = 0;
    if (pieChartData != null) {
      pieChartData.forEach((_, v) {
        pieTotal += v;
      });
    }
    final List<Map<String, double>> lineChartData = [];
    this.lineChartData.forEach((ele) {
      Map<String, double> temp = Map<String, double>.from(ele);
      List<String> keys = [];
      temp.forEach((k, v) {
        keys.add(k);
      });
      keys.forEach((k) {
        if (!this.selectedTypes.contains(k)) {
          temp.remove(k);
        }
      });
      lineChartData.add(temp);
    });
    bool showLineChart = false;
    if (lineChartData.length > 0 && currentMode == Mode.month) {
      lineChartData.forEach((ele) {
        ele.forEach((k, v) {
          showLineChart = true;
        });
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
                          value: Mode.six_month, child: Text('last 6 months')),
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
        body: ListView(
//          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: pieChartData.isEmpty
                              ? Container()
                              : Text(
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
                : Container(),
            showLineChart
                ? SizedBox(
                    height: 400,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            top: 5,
                            left: 10,
                            child: RaisedButton(
                                child: Text('Select'),
                                onPressed: () => _showSelectDialog(context))),
                        Container(
                            margin: EdgeInsets.only(top: 40),
                            child: LineChart(
                              lineChartData,
                              animate: true,
                            ))
                      ],
                    ))
                : Container(),
          ],
        ));
  }
}
