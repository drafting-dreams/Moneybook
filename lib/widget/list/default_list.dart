import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:provider/provider.dart';
import 'package:money_book/screens/expense_edit_screen.dart';
import 'package:money_book/screens/income_edit_screen.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/expense_type.dart';

enum DeleteType { NORMAL, CASCADE }

class DefaultList extends StatefulWidget {
  final Function onRefresh;

  DefaultList(this.onRefresh);

  @override
  _DefaultListState createState() => _DefaultListState();
}

class _DefaultListState extends State<DefaultList> {
  final SlidableController slidableController = SlidableController();

  final List<Map<String, int>> hiddenMonth = [];

  bool hiddenContained(int year, int month) =>
      hiddenMonth.indexWhere((Map element) =>
          element['year'] == year && element['month'] == month) !=
      -1;

  Future<DeleteType> _deletionDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Delete Transaction'),
              content: Text(
                  "Do you want this operation affect your account's balance?"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(DeleteType.CASCADE);
                  },
                ),
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(DeleteType.NORMAL);
                  },
                )
              ],
            ));
  }

  build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    var expenseTypeInfo = Provider.of<ExpenseTypeInfo>(context);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (BuildContext context, int index) {
            final transaction = transactions.get(index);
            final icon = transaction.value < 0
                ? expenseTypeInfo.types
                    .firstWhere((info) => info.name == transaction.type)
                : ExpenseType('income', Icons.monetization_on.toString(),
                    Colors.yellow.toString());
            final previous = index > 0 ? transactions.get(index - 1) : null;
            Widget leading = Container(height: 0);
            String total = '';

            if (previous == null ||
                transaction.date.year != previous.date.year ||
                transaction.date.month != previous.date.month) {
              final totalAmount =
                  transactions.getTotalOfMonth(transaction.date);
              total = (totalAmount > 0 ? '+' : '') + totalAmount.toString();
              leading = GestureDetector(
                  onTap: () {
                    setState(() {
                      if (hiddenContained(
                          transaction.date.year, transaction.date.month)) {
                        hiddenMonth.removeWhere((Map element) =>
                            element['year'] == transaction.date.year &&
                            element['month'] == transaction.date.month);
                      } else {
                        hiddenMonth.add({
                          'year': transaction.date.year,
                          'month': transaction.date.month
                        });
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blue[100]),
                    padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${transaction.date.year}/${transaction.date.month}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Container(),
                          ),
                          Text(total,
                              textAlign: TextAlign.right,
                              style: totalAmount > 0
                                  ? TextStyle(color: Colors.green[600])
                                  : TextStyle(color: Colors.red[600])),
                          hiddenContained(
                                  transaction.date.year, transaction.date.month)
                              ? Icon(Icons.arrow_left)
                              : Icon(Icons.arrow_drop_down)
                        ]),
                  ));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                leading,
                hiddenContained(transaction.date.year, transaction.date.month)
                    ? Container(
                        height: 0,
                      )
                    : Divider(
                        height: 2.0,
                      ),
                hiddenContained(transaction.date.year, transaction.date.month)
                    ? Container(
                        height: 0,
                      )
                    : Slidable(
                        key: ValueKey(index),
                        controller: slidableController,
                        actionPane: SlidableDrawerActionPane(),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Edit',
                            color: Colors.grey[350],
                            icon: Icons.edit,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                if (transaction.value >= 0) {
                                  return IncomeEditScreen(id: transaction.id);
                                }
                                return ExpenseEditScreen(id: transaction.id);
                              }));
                            },
                          ),
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              _deletionDialog(context).then((DeleteType type) {
                                if (type == DeleteType.NORMAL) {
                                  TransactionAPI.delete(transaction.id);
                                  transactions.removeById(transaction.id);
                                } else if (type == DeleteType.CASCADE) {
                                  TransactionAPI.delete(transaction.id,
                                      transaction.accountId, transaction.value);
                                  transactions.removeById(transaction.id);
                                }
                              });
                            },
                          )
                        ],
                        child: ListTile(
                          leading: RawMaterialButton(
                            constraints: BoxConstraints(
                                minWidth: 45,
                                minHeight: 45,
                                maxHeight: 45,
                                maxWidth: 45),
                            onPressed: () {},
                            shape: CircleBorder(),
                            child: Icon(icon.icon, color: Colors.white),
                            fillColor: icon.color,
                          ),
                          title: Text('${transaction.name}'),
                          subtitle: Text(
                            (transaction.value > 0 ? '+' : '') +
                                '${transaction.value}',
                            style: transaction.value >= 0
                                ? TextStyle(color: Colors.green[600])
                                : TextStyle(color: Colors.red[600]),
                          ),
                          trailing: Text(
                              '${transaction.date.day}/${transaction.date.month}'),
                        ),
                      ),
              ],
            );
          }),
    );
  }
}
