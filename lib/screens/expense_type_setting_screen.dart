import 'package:flutter/material.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum Confirmation { CANCEL, ACCEPT }

class ExpenseTypeSettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseTypeSettingScreen();
  }
}

class _ExpenseTypeSettingScreen extends State<ExpenseTypeSettingScreen> {
  final SlidableController slidableController = SlidableController();
  List<String> types = [];

  Future<Confirmation> _deletionConfirmDialog(
      BuildContext context, String type) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete type'),
            content: Text('You will delete the ' + type + ' type!'),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.red,
                child: Text('DELETE'),
                onPressed: () {
                  Navigator.of(context).pop(Confirmation.ACCEPT);
                },
              ),
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(Confirmation.CANCEL);
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    ExpenseTypeAPI.list().then((data) {
      setState(() {
        types = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Expense Type')),
        body: ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Divider(height: 2.0),
                  Slidable(
                      key: ValueKey(index),
                      controller: slidableController,
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            _deletionConfirmDialog(context, types[index])
                                .then((Confirmation confirmation) {
                              if (confirmation == Confirmation.ACCEPT) {
                                ExpenseTypeAPI.deleteType(types[index])
                                    .then((void v) {
                                  loadData();
                                });
                              }
                            });
                          },
                        )
                      ],
                      child: ListTile(
                        title: Text(types[index]),
                      ))
                ],
              );
            }));
  }
}
