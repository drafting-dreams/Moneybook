import 'package:flutter/material.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/screens/account_edit_screen.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:provider/provider.dart';

enum Confirmation { CANCEL, ACCEPT }

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountScreen();
  }
}

class _AccountScreen extends State<AccountScreen> {
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
        bottomNavigationBar: BottomNavigator(
          initialIndex: 2,
        ),
        body: ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                accountState.setCurrentAccount(accounts[index]);
                AccountAPI.setCurrentAccount(accounts[index].id);
              },
              child: Slidable(
                  key: ValueKey(index),
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        _deletionConfirmDialog(context)
                            .then((Confirmation confirmation) {
                          if (confirmation == Confirmation.ACCEPT) {
                            AccountAPI.deleteAccount(accounts[index].id)
                                .then((v) {
                              updateAccountsList();
                            });
                          }
                        });
                      },
                    ),
                  ],
                  child: ListTile(
                    title: accountState.currentAccount.id == accounts[index].id
                        ? Row(children: <Widget>[
                            Container(
                              width: 28,
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(Icons.check),
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
                    trailing: Text(accounts[index].balance.toString()),
                  )),
            );
          },
        ));
  }
}
