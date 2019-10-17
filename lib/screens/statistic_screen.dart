import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:money_book/widget/statistic/pie_chart.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/widget/statistic/line_chart.dart' as lineChart;
import 'package:money_book/widget/statistic/time_line_chart.dart' as timeChart;
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/locale/locales.dart';

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
  List<dynamic> selectionBoard = [];
  List<String> typeList;
  List<String> selectedTypes;
  List<DateTime> sevenDates = [];

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
    if (currentMode == Mode.seven) {
      var futures = <Future<Map<String, double>>>[];
      var dates = <DateTime>[];
      DateTime today = DateTime.now();
      DateTime sixDaysAgo = today.subtract(Duration(days: 6));
      for (var d = sixDaysAgo;
          d.compareTo(today) <= 0;
          d = d.add(Duration(days: 1))) {
        dates.add(d);
        futures.add(TransactionAPI.getSumByDayByGroup(accountId, d));
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
          this.sevenDates = dates;
        });
      });
    }
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

  _onSelectionChanged(charts.SelectionModel model) {
    setState(() {
      selectionBoard = [];
      final selectedDatum = model.selectedDatum;
      if (selectedDatum.isNotEmpty) {
        selectedDatum.forEach((datumPair) {
          selectionBoard.add(datumPair.datum);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context);
    Locale myLocale = Localizations.localeOf(context);
    double pieTotal = 0;
    if (pieChartData != null) {
      pieChartData.forEach((_, v) {
        pieTotal += v;
      });
    }
    bool showLineChart = false;
    if (lineChartData.any((element) => element.length != 0) &&
        (currentMode == Mode.month || currentMode == Mode.seven)) {
      showLineChart = true;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(localizer.statistic),
          actions: <Widget>[
            PopupMenuButton(
                icon: Icon(Icons.menu),
                initialValue: currentMode,
                onSelected: (Mode mode) {
                  setState(() {
                    currentMode = mode;
                    selectionBoard = [];
                    loadData();
                  });
                },
                itemBuilder: (BuildContext context) => [
                      PopupMenuItem<Mode>(
                          value: Mode.seven, child: Text(localizer.seven)),
                      PopupMenuItem<Mode>(
                          value: Mode.thirty, child: Text(localizer.thirty)),
                      PopupMenuItem<Mode>(
                          value: Mode.six_month,
                          child: Text(localizer.lastSix)),
                      PopupMenuItem<Mode>(
                          value: Mode.month, child: Text(localizer.byMonth)),
                      PopupMenuItem<Mode>(
                          value: Mode.year, child: Text(localizer.byYear)),
                    ])
          ],
        ),
        bottomNavigationBar: BottomNavigator(
          initialIndex: 2,
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
                                              child: Text(myLocale.languageCode
                                                      .contains('zh')
                                                  ? Util.getMonthName(
                                                      value)['zh']
                                                  : Util.getMonthName(
                                                      value)['en'])))
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
                                  '${localizer.total}   ${-pieTotal}',
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
                    height: 600,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(top: 40),
                            child: currentMode == Mode.seven
                                ? timeChart.TimeLineChart(lineChartData,
                                    this._onSelectionChanged, sevenDates,
                                    animate: false)
                                : lineChart.LineChart(
                                    lineChartData,
                                    year,
                                    this._onSelectionChanged,
                                    animate: false,
                                  )),
                        selectionBoard.length > 0
                            ? Positioned(
                                top: 110,
                                right: 10,
                                child: Container(
                                  width: 220,
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Color.fromRGBO(0, 0, 0, .6)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: selectionBoard
                                        .map((datum) => Text(
                                              '${datum.type}: ${datum.value < 0 ? -datum.value : datum.value}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))
                                        .toList(),
                                  ),
                                ))
                            : Container(),
                      ],
                    ))
                : Container(),
          ],
        ));
  }
}
