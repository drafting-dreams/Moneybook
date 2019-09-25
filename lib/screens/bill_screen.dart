import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/screens/bill_edit_screen.dart';
import 'package:money_book/model/bill.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/api/bill.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:provider/provider.dart';

enum DeleteType { YES, NO }

class BillScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BillScreenState();
  }
}

class _BillScreenState extends State<BillScreen> {
  final SlidableController slidableController = SlidableController();
  List<Bill> defaultList = [];
  List<Bill> customizedList = [];
  final List<Map<String, int>> defaultHiddenList = [];
  final List<Map<String, int>> customizedHiddenList = [];
  String mode = 'default';
  Account currentAccount;
  bool loading = false;
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  bool hiddenContained(
          List<Map<String, int>> hiddenList, int year, int month) =>
      hiddenList.indexWhere((Map element) =>
          element['year'] == year && element['month'] == month) !=
      -1;

  @override
  void initState() {
    super.initState();
    AccountAPI.getCurrentAccount().then((account) {
      setState(() {
        currentAccount = account;
      });
      final now = DateTime.now();
      BillAPI.getListAfterDate(account.id, DateTime(now.year, now.month, 1))
          .then((bills) {
        setState(() {
          defaultList.addAll(bills);
        });
      });
    });
  }

  reload() {
    final now = DateTime.now();
    BillAPI.getListAfterDate(
            currentAccount.id, DateTime(now.year, now.month, 1))
        .then((bills) {
      setState(() {
        defaultList.clear();
        defaultList.addAll(bills);
      });
    });
  }

//  loadNextMonth() {
//    this.loading = true;
//    DateTime reference = mode == 'default'
//        ? defaultList.last.dueDate
//        : customizedList.last.dueDate;
//    BillAPI.loadNext(currentAccount.id, reference).then((bills) {
//      setState(() {
//        if (mode == 'default') {
//          defaultList.addAll(bills);
//        } else {
//          customizedList.addAll(bills);
//        }
//      });
//      this.loading = false;
//    });
//  }

  Future<DeleteType> _deletionDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Delete Bill'),
              content: Text("Delete this bill record."),
              actions: <Widget>[
                FlatButton(
                  child: Text('Yes', style: TextStyle(color: Colors.red[600])),
                  onPressed: () {
                    Navigator.of(context).pop(DeleteType.YES);
                  },
                ),
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(DeleteType.NO);
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    var expenseTypeInfo = Provider.of<ExpenseTypeInfo>(context);

    List<Bill> bills = mode == 'default' ? defaultList : customizedList;
    List<Map<String, int>> hiddenList =
        mode == 'default' ? defaultHiddenList : customizedHiddenList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => BillEditScreen()))
                .then((v) {
              reload();
            });
          }),
      body: RefreshIndicator(
        onRefresh: () {},
        child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: bills.length,
            itemBuilder: (BuildContext context, int index) {
              Bill bill = bills[index];
              bool hideItem = hiddenContained(
                  hiddenList, bill.dueDate.year, bill.dueDate.month);
              final icon = expenseTypeInfo.types
                  .firstWhere((info) => info.name == bill.type);
              Widget leading = Container();
              final previous = index > 0 ? bills[index - 1] : null;
              if (previous == null ||
                  bill.dueDate.year != previous.dueDate.year ||
                  bill.dueDate.month != previous.dueDate.month) {
                leading = GestureDetector(
                    onTap: () {
                      setState(() {
                        if (hideItem) {
                          hiddenList.removeWhere((element) =>
                              element['year'] == bill.dueDate.year &&
                              element['month'] == bill.dueDate.month);
                        } else {
                          hiddenList.add({
                            'year': bill.dueDate.year,
                            'month': bill.dueDate.month
                          });
                        }
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(color: Colors.blue[100]),
                        padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${bill.dueDate.year}/${bill.dueDate.month}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Expanded(child: Container()),
                            hideItem
                                ? Icon(Icons.arrow_left)
                                : Icon(Icons.arrow_drop_down)
                          ],
                        )));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  leading,
                  hideItem ? Container() : Divider(height: 2),
                  hideItem
                      ? Container()
                      : Slidable(
                          key: ValueKey(index),
                          controller: slidableController,
                          actionPane: SlidableDrawerActionPane(),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  _deletionDialog(context)
                                      .then((DeleteType type) {
                                    if (type == DeleteType.YES) {
                                      BillAPI.deleteById(bill.id);
                                      setState(() {
                                        if (mode == 'default') {
                                          defaultList.removeWhere(
                                              (item) => item.id == bill.id);
                                        } else {
                                          customizedList.removeWhere(
                                              (item) => item.id == bill.id);
                                        }
                                      });
                                    }
                                  });
                                })
                          ],
                          child: ListTile(
                            leading: RawMaterialButton(
                              constraints:
                                  BoxConstraints(minHeight: 45, minWidth: 45),
                              onPressed: () {},
                              shape: CircleBorder(),
                              child: Icon(icon.icon, color: Colors.white),
                              fillColor: icon.color,
                            ),
                            title: Text('${bill.name}'),
                            subtitle: Text('${bill.value}',
                                style: TextStyle(color: Colors.red[600])),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.check_circle,
                                        color: bill.paid
                                            ? Colors.green[600]
                                            : Colors.grey),
                                  ),
                                  Text(
                                      '${bill.dueDate.day}/${bill.dueDate.month}'),
                                ],
                              ),
                            ),
                          ))
                ],
              );
            }),
      ),
      bottomNavigationBar: BottomNavigator(initialIndex: 1),
    );
  }
}
