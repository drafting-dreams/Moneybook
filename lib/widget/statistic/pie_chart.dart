/// Simple pie chart with outside labels example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:money_book/locale/locales.dart';

class PieOutsideLabelChart extends StatelessWidget {
  Map<String, double> data;
  final bool animate;

  PieOutsideLabelChart(this.data, {this.animate});

  List<charts.Series<TransactionStatistic, String>> data2Series(
      Map<String, double> data) {
    final List<TransactionStatistic> statistic = [];
    data.forEach((key, val) {
      statistic.add(TransactionStatistic(type: key, value: val));
    });
    return [
      charts.Series<TransactionStatistic, String>(
        id: 'pie_chart',
        colorFn: (_, idx) {
          return charts.MaterialPalette.getOrderedPalettes(12)[idx % 11]
              .shadeDefault;
        },
        domainFn: (TransactionStatistic t, _) => t.type,
        measureFn: (TransactionStatistic t, _) => num.parse(t.value.toStringAsFixed(2)),
        data: statistic,
        labelAccessorFn: (TransactionStatistic t, _) => t.type,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizer = AppLocalizations.of(context);

    if (data.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(
              Icons.error_outline,
              size: 120,
              color: Theme.of(context).accentColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                localizer.chartWarn,
                style: TextStyle(),
              ),
            ],
          ),
        ],
      );
    }
    return new charts.PieChart(data2Series(data),
        behaviors: [
          charts.ChartTitle(localizer.ratioChart,
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.middle,
              innerPadding: 10,
              outerPadding: 25),
          charts.DatumLegend(
              position: charts.BehaviorPosition.end,
              cellPadding: EdgeInsets.only(top:6.0, right: 30),
              showMeasures: true,
              horizontalFirst: false,
              legendDefaultMeasure: charts.LegendDefaultMeasure.average,
              measureFormatter: (num v) => '${-v}'),
        ],
        animate: animate,
        // Add an [ArcLabelDecorator] configured to render labels outside of the
        // arc with a leader line.
        //
        // Text style for inside / outside can be controlled independently by
        // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
        //
        // Example configuring different styles for inside/outside:
        //       new charts.ArcLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        defaultRenderer: new charts.ArcRendererConfig(
            arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }
}

class TransactionStatistic {
  final String type;
  final double value;

  TransactionStatistic({this.type, this.value});
}
