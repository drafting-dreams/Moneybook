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

  Future<String> _inputDialog(BuildContext context, String old) async {
    TextEditingController controller = TextEditingController();
    controller.text = old;
    return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter the type name'),
            content: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Type Name',
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(
                  'Confirm',
                ),
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
              )
            ],
          );
        });
  }

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

  Future<Confirmation> _fallbackDialog(BuildContext context) {
    final content = types.length == 1
        ? 'There must be at least one expense type.'
        : "The  maximum number of expense type is 12.";
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

  void createOrModifyType(BuildContext context, [String oldName = '']) {
    _inputDialog(context, oldName).then((String name) {
      print(name);
      if (name.length < 1) {
        showDialog<Confirmation>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Wrong name'),
              content: Text('Please enter a name'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(Confirmation.ACCEPT);
                  },
                )
              ],
            );
          },
        ).then((Confirmation cf) {
          if (cf == Confirmation.ACCEPT) {
            createOrModifyType(context);
          }
        });
      } else if (this.types.contains(name)) {
        showDialog<Confirmation>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Duplicated name'),
              content: Text('Please enter another name'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(Confirmation.ACCEPT);
                  },
                )
              ],
            );
          },
        ).then((Confirmation cf) {
          if (cf == Confirmation.ACCEPT) {
            createOrModifyType(context);
          }
        });
      } else {
        if (oldName.length == 0) {
          ExpenseTypeAPI.createType(name).then((void v) {
            loadData();
          });
        } else {
          ExpenseTypeAPI.modifyType(oldName, name).then((void v) {
            loadData();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Expense Type'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                if (types.length == 12) {
                  _fallbackDialog(context);
                  return;
                }
                createOrModifyType(context);
              },
            )
          ],
        ),
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
                            caption: 'Edit',
                            color: Colors.grey[350],
                            icon: Icons.edit,
                            onTap: () {
                              createOrModifyType(context, types[index]);
                            }),
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            if (types.length == 1) {
                              _fallbackDialog(context);
                              return;
                            }
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
