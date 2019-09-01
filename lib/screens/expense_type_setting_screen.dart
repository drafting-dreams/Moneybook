import 'package:flutter/material.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/screens/expense_type_add_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/model/expense_type.dart';
import 'package:provider/provider.dart';

enum Confirmation { CANCEL, ACCEPT }

class ExpenseTypeSettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseTypeSettingScreen();
  }
}

class _ExpenseTypeSettingScreen extends State<ExpenseTypeSettingScreen> {
  final SlidableController slidableController = SlidableController();

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

  Future<Confirmation> _fallbackDialog(BuildContext context, int len) {
    final content = len == 1
        ? 'There must be at least one expense type.'
        : "The  maximum number of expense type is 11.";
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Types number limit'),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(Confirmation.ACCEPT);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  void createOrModifyType(BuildContext context, [ExpenseType oldType]) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ExpenseTypeAddScreen(oldType)));
  }

  @override
  Widget build(BuildContext context) {
    var expenseTypeInfo = Provider.of<ExpenseTypeInfo>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Expense Type'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                if (expenseTypeInfo.types.length == 11) {
                  _fallbackDialog(context, 11);
                  return;
                }
                createOrModifyType(context);
              },
            )
          ],
        ),
        body: ListView.builder(
            itemCount: expenseTypeInfo.types.length,
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
                            caption: 'Edit',
                            color: Colors.grey[350],
                            icon: Icons.edit,
                            onTap: () {
                              createOrModifyType(context, expenseTypeInfo.types[index]);
                            }),
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            if (expenseTypeInfo.types.length == 1) {
                              _fallbackDialog(context, 1);
                              return;
                            }
                            _deletionConfirmDialog(context, expenseTypeInfo.types[index].name)
                                .then((Confirmation confirmation) {
                              if (confirmation == Confirmation.ACCEPT) {
                                ExpenseTypeAPI.deleteType(expenseTypeInfo.types[index].name)
                                    .then((void v) {
                                expenseTypeInfo.delete(expenseTypeInfo.types[index].name);
                                });
                              }
                            });
                          },
                        )
                      ],
                      child: ListTile(
                        leading: RawMaterialButton(
                          onPressed: () {},
                          constraints: BoxConstraints(minWidth: 35, minHeight: 35),
                          shape: CircleBorder(),
                          child: Icon(expenseTypeInfo.types[index].icon,
                            color: Colors.white),
                          fillColor: expenseTypeInfo.types[index].color,
                        ),
                        title: Text(expenseTypeInfo.types[index].name),
                      ))
                ],
              );
            }));
  }
}
