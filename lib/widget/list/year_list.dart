import 'package:flutter/material.dart';

class YearList extends StatelessWidget {
  final List<Map<String, dynamic>> yearTransactionTotalList;

  YearList(this.yearTransactionTotalList);

  build(BuildContext context) {
    return ListView.builder(itemCount: yearTransactionTotalList.length, itemBuilder: (BuildContext context, int index) {
      final e = yearTransactionTotalList[index];
      return Column(
        children: <Widget>[
          Divider(height: 2.0),
          ListTile(
            title: Text(e['year'].toString()),
            trailing: Text((e['amount'] > 0 ? '+' : '') + e['amount'].toStringAsFixed(2),
                style: TextStyle(
                    color:
                        e['amount'] > 0 ? Colors.green[600] : Colors.red[600])),
          )
        ],
      );
    });
  }
}
