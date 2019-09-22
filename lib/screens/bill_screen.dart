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

class BillScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BillScreenState();
  }
}

class _BillScreenState extends State<BillScreen> {
  final SlidableController slidableController = SlidableController();
  final List<Bill> defaultList = [];
  final List<Bill> customizedList = [];
  final List<Map<String, int>> defaultHiddenList = [];
  final List<Map<String, int>> customizedHiddenList = [];
  String mode = 'default';
  Account currentAccount;

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
      BillAPI.getOneMonthList(account.id, DateTime.now()).then((bills) {
        setState(() {
          defaultList.addAll(bills);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var expenseTypeInfo = Provider.of<ExpenseTypeInfo>(context);

    List<Bill> bills = mode == 'default' ? defaultList : customizedList;
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
                    builder: (BuildContext context) => BillEditScreen()));
          }),
      body: RefreshIndicator(
          onRefresh: () {},
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bills.length,
              itemBuilder: (BuildContext context, int index) {
                Bill bill = bills[index];
                bool hideItem = hiddenContained(
                    mode == 'default'
                        ? defaultHiddenList
                        : customizedHiddenList,
                    bill.dueDate.year,
                    bill.dueDate.month);
                final icon = expenseTypeInfo.types
                    .firstWhere((info) => info.name == bill.type);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    hideItem ? Container() : Divider(height: 2),
                    hideItem
                        ? Container()
                        : Slidable(
                            key: ValueKey(index),
                            controller: slidableController,
                            actionPane: SlidableDrawerActionPane(),
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
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
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
              })),
      bottomNavigationBar: BottomNavigator(initialIndex: 1),
    );
  }
}
