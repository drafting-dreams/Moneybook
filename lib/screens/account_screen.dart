import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/screens/account_edit_screen.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/transaction.dart';

enum Confirmation { CANCEL, ACCEPT }

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountScreen();
  }
}

class _AccountScreen extends State<AccountScreen> {
  final SlidableController slidableController = SlidableController();
  List<Account> accounts = [];

  void initState() {
    super.initState();
    updateAccountsList();
  }

  void updateAccountsList() {
    AccountAPI.getAll().then((List<Account> all) {
      setState(() {
        this.accounts = all;
      });
    });
  }

  Future<Confirmation> _deletionConfirmDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Account'),
            content: Text(
                'All related information including transactions and bills will be deleted, are you sure?'),
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
  Widget build(BuildContext context) {
    var accountState = Provider.of<AccountState>(context);
    var transactions = Provider.of<Transactions>(context);

    List<Widget> actions(index) {
      var secondaryActions = <Widget>[
        IconSlideAction(
          caption: 'Edit',
          color: Colors.grey[350],
          icon: Icons.edit,
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AccountEditScreen(id: accounts[index].id)))
                .then((value) {
              updateAccountsList();
            });
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deletionConfirmDialog(context).then((Confirmation confirmation) {
              if (confirmation == Confirmation.ACCEPT) {
                AccountAPI.deleteAccount(accounts[index].id).then((v) {
                  updateAccountsList();
                });
              }
            });
          },
        ),
      ];
      if (accountState.currentAccount.id == accounts[index].id) {
        secondaryActions.removeLast();
      }
      return secondaryActions;
    }

    return Scaffold(
        appBar: AppBar(title: Text('Account'), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AccountEditScreen())).then((value) {
                updateAccountsList();
              });
            },
          )
        ]),
        body: ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Divider(height: 2.0),
                InkWell(
                  onTap: () {
                    accountState.setCurrentAccount(accounts[index]);
                    AccountAPI.setCurrentAccount(accounts[index].id);
                    final now = DateTime.now();
                    final nextMonth = now.month == 12
                        ? DateTime(now.year + 1, now.month, 1)
                        : DateTime(now.year, now.month + 1, 1);
                    TransactionAPI.loadPrevious(
                            accountState.currentAccount.id, nextMonth)
                        .then((List<Transaction> ts) {
                      setState(() {
                        transactions.clear();
                        transactions.addAll(ts);
                      });
                    });
                  },
                  child: Slidable(
                      key: ValueKey(index),
                      controller: slidableController,
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: actions(index),
                      child: ListTile(
                        title: accountState.currentAccount.id == accounts[index].id
                            ? Row(children: <Widget>[
                                Container(
                                  width: 28,
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(accounts[index].name)
                              ])
                            : Row(
                                children: <Widget>[
                                  Container(
                                      width: 28,
                                      margin: EdgeInsets.only(right: 10)),
                                  Text(accounts[index].name)
                                ],
                              ),
                        trailing: Text(accounts[index].balance.toString(),
                            style: accounts[index].balance >= 0
                                ? TextStyle(color: Colors.green[600])
                                : TextStyle(color: Colors.red[600])),
                      )),
                ),
              ],
            );
          },
        ));
  }
}
