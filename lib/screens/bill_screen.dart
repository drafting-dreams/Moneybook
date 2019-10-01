import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/screens/bill_edit_screen.dart';
import 'package:money_book/model/bill.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/api/bill.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';
import 'package:money_book/widget/expanded_section.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/widget/paid_dialog.dart';

enum DeleteType { YES, NO }
enum Payment { ALL, PAID, UNPAID }

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
  int startYear = DateTime.now().year;
  int endYear = DateTime.now().year;
  int startMonth = 1;
  int endMonth = 12;
  bool expand = false;
  Payment paymentFilter = Payment.ALL;

  setPayment(Payment p) {
    setState(() {
      paymentFilter = p;
    });
  }

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

  Future<void> _onRefresh() async {
    loadPreviousMonth();
  }

  loadPreviousMonth() {
    if (mode == 'default') {
      BillAPI.loadPrevious(
              currentAccount.id,
              defaultList.length > 0
                  ? defaultList.first.dueDate
                  : DateTime.now())
          .then((previousMonthBills) {
        setState(() {
          defaultList = previousMonthBills..addAll(defaultList);
        });
      });
    }
  }

  getCustomeList() {
    BillAPI.getListByDate(
            currentAccount.id,
            DateTime(startYear, startMonth),
            endMonth == 12
                ? DateTime(endYear + 1, 1, 0)
                : DateTime(endYear, endMonth + 1, 0))
        .then((data) {
      final temp = <Map<String, int>>[];
      for (Bill item in data) {
        final date = item.dueDate;
        if (temp.indexWhere((map) =>
                map['year'] == date.year && map['month'] == date.month) ==
            -1) {
          customizedHiddenList.add({'year': date.year, 'month': date.month});
        }
      }
      setState(() {
        customizedList = data;
      });
    });
  }

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
    var transactions = Provider.of<Transactions>(context);

    List<Bill> bills = mode == 'default' ? defaultList : customizedList;
    if (paymentFilter == Payment.PAID) {
      bills = bills.where((b) => b.paid).toList();
    } else if (paymentFilter == Payment.UNPAID) {
      bills = bills.where((b) => !b.paid).toList();
    }
    List<Map<String, int>> hiddenList =
        mode == 'default' ? defaultHiddenList : customizedHiddenList;
    List<Widget> actions(Bill bill) {
      List<Widget> list = [
        IconSlideAction(
            caption: 'Edit',
            color: Colors.grey,
            icon: Icons.edit,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          BillEditScreen(id: bill.id))).then((paidToday) {
                if (paidToday ?? false) {
                  paySuccessfulDialog(
                      context, "Today's bill has been successfully paid!");
                }
                reload();
              });
            }),
        IconSlideAction(
            caption: 'Pay',
            color: Colors.green,
            icon: Icons.account_balance_wallet,
            onTap: () {
              Transaction t = Transaction(
                  bill.value, DateTime.now(), bill.accountId,
                  type: bill.type, name: bill.name);
              BillAPI.pay(bill.id, t);
              paySuccessfulDialog(
                  context, 'The bill has been successfully paid.');
              setState(() {
                bills.firstWhere((element) => element.id == bill.id).paid =
                    true;
              });
              transactions.add(t);
            }),
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              _deletionDialog(context).then((DeleteType type) {
                if (type == DeleteType.YES) {
                  BillAPI.deleteById(bill.id);
                  setState(() {
                    if (mode == 'default') {
                      defaultList.removeWhere((item) => item.id == bill.id);
                    } else {
                      customizedList.removeWhere((item) => item.id == bill.id);
                    }
                  });
                }
              });
            })
      ];
      if (bill.paid) {
        list = list.sublist(2);
      }
      return list;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill'),
        actions: <Widget>[
          Builder(
            builder: (innerContext) => IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () => Scaffold.of(innerContext).openEndDrawer(),
                ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => BillEditScreen()))
                .then((paidToday) {
              if (paidToday ?? false) {
                paySuccessfulDialog(
                    context, "Today's bill has been successfully paid!");
              }
              reload();
            });
          }),
      endDrawer: Drawer(
          child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Text('Payment Status',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey[700])))),
          RadioListTile<Payment>(
            value: Payment.ALL,
            title: Text('All'),
            groupValue: paymentFilter,
            onChanged: setPayment,
          ),
          RadioListTile<Payment>(
            value: Payment.PAID,
            title: Text('Paid'),
            groupValue: paymentFilter,
            onChanged: setPayment,
          ),
          RadioListTile<Payment>(
            value: Payment.UNPAID,
            title: Text('Unpaid'),
            groupValue: paymentFilter,
            onChanged: setPayment,
          ),
          Divider(height: 2.0),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                  child: Text('Time',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey[700])))),
          RadioListTile<String>(
              value: 'default',
              title: Text('Default'),
              groupValue: mode,
              onChanged: (String newMode) {
                if (newMode != mode) {
                  setState(() {
                    mode = newMode;
                    expand = false;
                  });
                  reload();
                }
              }),
          RadioListTile<String>(
            value: 'customize',
            title: Text('Customize'),
            groupValue: mode,
            onChanged: (String newMode) {
              if (newMode != mode) {
                setState(() {
                  mode = newMode;
                  expand = true;
                });
                getCustomeList();
              }
            },
          ),
          ExpandedSection(
              expand: expand,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                              width: 50,
                              margin: EdgeInsets.only(left: 26),
                              child: Text('From ')),
                          DropdownButton<int>(
                              value: startYear,
                              items: <int>[
                                for (var i = 2019;
                                    i <= DateTime.now().year;
                                    i += 1)
                                  i
                              ]
                                  .map<DropdownMenuItem<int>>((int value) =>
                                      DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString())))
                                  .toList(),
                              onChanged: (int i) {
                                startYear = i;
                              }),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('-')),
                          DropdownButton<int>(
                              value: startMonth,
                              onChanged: (int i) {
                                setState(() {
                                  startMonth = i;
                                });
                              },
                              items: <int>[for (var i = 1; i <= 12; i += 1) i]
                                  .map<DropdownMenuItem<int>>((int value) =>
                                      DropdownMenuItem<int>(
                                          value: value,
                                          child:
                                              Text(Util.getMonthName(value))))
                                  .toList()),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                              width: 50,
                              margin: EdgeInsets.only(left: 26),
                              child: Text(' to ')),
                          DropdownButton<int>(
                              value: endYear,
                              onChanged: (int i) {
                                setState(() {
                                  endYear = i;
                                });
                              },
                              items: <int>[
                                for (var i = 2019;
                                    i <= DateTime.now().year;
                                    i += 1)
                                  i
                              ]
                                  .map<DropdownMenuItem<int>>((int value) =>
                                      DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString())))
                                  .toList()),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('-')),
                          DropdownButton<int>(
                              value: endMonth,
                              onChanged: (int i) {
                                setState(() {
                                  endMonth = i;
                                });
                              },
                              items: <int>[for (var i = 1; i <= 12; i += 1) i]
                                  .map<DropdownMenuItem<int>>((int value) =>
                                      DropdownMenuItem<int>(
                                          value: value,
                                          child:
                                              Text(Util.getMonthName(value))))
                                  .toList()),
                        ],
                      )
                    ],
                  ),
                  Transform.translate(
                    offset: Offset(0, 4),
                    child: Container(
                        padding: EdgeInsets.only(
                          left: 1,
                        ),
                        child: SizedBox(
                          width: 72,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.lightBlueAccent,
                              padding: EdgeInsets.symmetric(
                                vertical: 19,
                              ),
                              onPressed: () {
                                getCustomeList();
                              },
                              child: Text('Filter\nRange')),
                        )),
                  )
                ],
              ))
        ],
      )),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
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
                          secondaryActions: actions(bill),
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
                                  SizedBox(
                                    width: 40,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          '${bill.dueDate.day}/${bill.dueDate.month}'),
                                    ),
                                  ),
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
