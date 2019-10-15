import 'package:flutter/material.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/bill.dart';
import 'package:money_book/app.dart';
import 'package:money_book/screens/expense_type_add_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/model/expense_type.dart';
import 'package:provider/provider.dart';
import 'package:money_book/locale/locales.dart';

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
    final localizer = AppLocalizations.of(context);
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizer.deleteType),
            content: Text(
                '${localizer.confirmDeleteType1}$type${localizer.confirmDeleteType2}'),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.red,
                child: Text(localizer.delete),
                onPressed: () {
                  Navigator.of(context).pop(Confirmation.ACCEPT);
                },
              ),
              FlatButton(
                child: Text(localizer.cancel),
                onPressed: () {
                  Navigator.of(context).pop(Confirmation.CANCEL);
                },
              )
            ],
          );
        });
  }

  Future<Confirmation> _fallbackDialog(BuildContext context, int len) {
    final localizer = AppLocalizations.of(context);
    final content = len == 1 ? localizer.oneType : localizer.maximumType;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizer.typeNumberLimit),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(Confirmation.ACCEPT);
                  },
                  child: Text(localizer.ok))
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
    var transacitons = Provider.of<Transactions>(context);
    final localizer = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(localizer.expenseType),
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
                            caption: localizer.edit,
                            color: Colors.grey[350],
                            icon: Icons.edit,
                            onTap: () {
                              createOrModifyType(
                                  context, expenseTypeInfo.types[index]);
                            }),
                        IconSlideAction(
                          caption: localizer.delete,
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            if (expenseTypeInfo.types.length == 1) {
                              _fallbackDialog(context, 1);
                              return;
                            }
                            _deletionConfirmDialog(
                                    context, expenseTypeInfo.types[index].name)
                                .then((Confirmation confirmation) {
                              if (confirmation == Confirmation.ACCEPT) {
                                final String typeName =
                                    expenseTypeInfo.types[index].name;
                                BillAPI.deleteByType(typeName);
                                TransactionAPI.deleteByType(typeName);
                                ExpenseTypeAPI.deleteType(typeName)
                                    .then((void v) {
                                  transacitons.removeByType(typeName);
                                  expenseTypeInfo.delete(typeName);
                                });
                              }
                            });
                          },
                        )
                      ],
                      child: ListTile(
                        leading: RawMaterialButton(
                          onPressed: () {},
                          constraints:
                              BoxConstraints(minWidth: 35, minHeight: 35),
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
