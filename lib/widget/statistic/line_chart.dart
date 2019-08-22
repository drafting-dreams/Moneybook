import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:money_book/screens/statistic_screen.dart';

class LineChart extends StatelessWidget {
  List<Map<String, double>> data;
  final bool animate;
  Mode type;
  int timeReference;

  LineChart(this.type, this.data, {this.timeReference, this.animate});

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
          statistics = List(12);
        } else {
          statistics = re[index];
        }
        statistics[i] = TransactionStatistic(transactionType, value, month: i);
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
          ss[i] = TransactionStatistic(notNull.type, 0, month: i);
        }
      }
    });
    return re.map((statistic) {
      return charts.Series<TransactionStatistic, num>(
        id: statistic[0].type,
        data: statistic,
        domainFn: (TransactionStatistic t, idx) => idx + 1,
        measureFn: (TransactionStatistic t, idx) => -t.value,
        labelAccessorFn: (TransactionStatistic t, _) => t.type,
      );
    }).toList();
  }

  Widget build(BuildContext context) {
    return charts.LineChart(
      data2Series(data),
      animate: animate,
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      behaviors: [
        charts.ChartTitle('Expense trend chart',
        behaviorPosition: charts.BehaviorPosition.top,
        titleOutsideJustification: charts.OutsideJustification.middle,
        innerPadding: 30,
        outerPadding: 25,),
        charts.SeriesLegend(
          position: charts.BehaviorPosition.start,
        )
      ],
    );
  }
}

class TransactionStatistic {
  // Transaction Type
  final String type;
  final int year;
  final int month;
  final double value;

  TransactionStatistic(this.type, this.value, {this.year, this.month});
}
