import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  List<Map<String, double>> data;
  final bool animate;
  final Function onSelected;
  final int year;

  LineChart(this.data, this.year, this.onSelected, {this.animate});

  List<charts.Series<TransactionStatistic, num>> data2Series(
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
        statistics[i] = TransactionStatistic(transactionType, value, i + 1);
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
          ss[i] = TransactionStatistic(notNull.type, 0, i + 1);
        }
      }
    });
    return re.map((statistic) {
      return charts.Series<TransactionStatistic, num>(
        id: statistic[0].type,
        data: statistic,
        domainFn: (TransactionStatistic t, idx) => t.time,
        measureFn: (TransactionStatistic t, idx) => -t.value,
        labelAccessorFn: (TransactionStatistic t, _) => t.type,
      );
    }).toList();
  }

  Widget build(BuildContext context) {
    return charts.LineChart(
      data2Series(data),
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(desiredTickCount: 5)),
      domainAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(zeroBound: false)),
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      behaviors: [
        charts.ChartTitle(
          '$year Expense trend chart',
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
  final int time;
  final double value;

  TransactionStatistic(this.type, this.value, this.time);
}
