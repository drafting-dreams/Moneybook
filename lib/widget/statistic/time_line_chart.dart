import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:money_book/locale/locales.dart';

class TimeLineChart extends StatelessWidget {
  List<Map<String, double>> data;
  final bool animate;
  final Function onSelected;
  final List<DateTime> dates;

  TimeLineChart(this.data, this.onSelected, this.dates,
      {this.animate});

  List<charts.Series<TransactionStatistic, DateTime>> data2Series(
      List<Map<String, double>> data) {
    final List<List<TransactionStatistic>> re = [];
    // Iterate through the twelve months or years, if this.type is month
    // then the data.length should be 12
    for (var i = 0; i < data.length; i++) {
      List<TransactionStatistic> statistics;
      // Iterate each month's type
      data[i].forEach((transactionType, value) {
        final index = re.indexWhere((ss) {
          for (var j = 0; j < ss.length; j++) {
            if (ss[j] != null) {
              if (ss[j].type == transactionType) {
                return true;
              }
            }
          }
          return false;
        });
        // Get the statistic list corresponding to the type
        if (index < 0) {
          statistics = List(data.length);
        } else {
          statistics = re[index];
        }
        statistics[i] = TransactionStatistic(transactionType, value, dates[i]);
        if (index < 0) {
          re.add(statistics);
        }
      });
    }

    // Fill the null value in lists in re
    re.forEach((ss) {
      TransactionStatistic notNull = ss[ss.indexWhere((s) => s != null)];
      for (var i = 0; i < ss.length; i++) {
        if (ss[i] == null) {
          ss[i] = TransactionStatistic(notNull.type, 0, dates[i]);
        }
      }
    });
    return re.map((statistic) {
      return charts.Series<TransactionStatistic, DateTime>(
        id: statistic[0].type,
        data: statistic,
        domainFn: (TransactionStatistic t, idx) => t.time,
        measureFn: (TransactionStatistic t, idx) => -t.value,
        labelAccessorFn: (TransactionStatistic t, _) => t.type,
      );
    }).toList();
  }

  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context);

    if (data.length != dates.length) {
      return Container();
    }
    return charts.TimeSeriesChart(
      data2Series(data),
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(desiredTickCount: 5)),
      domainAxis: new charts.EndPointsTimeAxisSpec(),
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      behaviors: [
        charts.ChartTitle(
          localizer.trend7,
          behaviorPosition: charts.BehaviorPosition.top,
          titleOutsideJustification: charts.OutsideJustification.middle,
          innerPadding: 30,
          outerPadding: 25,
        ),
        charts.SeriesLegend(
            position: charts.BehaviorPosition.bottom, desiredMaxColumns: 3),
      ],
      selectionModels: [
        charts.SelectionModelConfig(changedListener: onSelected)
      ],
    );
  }
}

class TransactionStatistic {
  // Transaction Type
  final String type;
  final DateTime time;
  final double value;

  TransactionStatistic(this.type, this.value, this.time);
}
