import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/screens/account_edit_screen.dart';
import 'package:money_book/screens/account_transfer_screen.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/locale/locales.dart';

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
    final localizer = AppLocalizations.of(context);
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizer.deleteAccount),
            content: Text(localizer.confirmDeleteAccount),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.red,
                child: Text(localizer.bigDelete),
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

  @override
  Widget build(BuildContext context) {
    var accountState = Provider.of<AccountState>(context);
    var transactions = Provider.of<Transactions>(context);
    final localizer = AppLocalizations.of(context);

    List<Widget> actions(index) {
      var secondaryActions = <Widget>[
        IconSlideAction(
          caption: localizer.edit,
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
          caption: localizer.delete,
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

    List<Widget> renderAccounts() {
      return accounts.asMap().entries.map((entry) {
        final account = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Divider(height: 2.0),
            InkWell(
              onTap: () {
                accountState.setCurrentAccount(account);
                AccountAPI.setCurrentAccount(account.id);
                final now = DateTime.now();
                final nextMonth = now.month == 12
                    ? DateTime(now.year + 1, 1, 1)
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
                  key: ValueKey(entry.key),
                  controller: slidableController,
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: actions(entry.key),
                  child: ListTile(
                    title: accountState.currentAccount.id == account.id
                        ? Row(children: <Widget>[
                            Container(
                              width: 28,
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                            Text(account.name)
                          ])
                        : Row(
                            children: <Widget>[
                              Container(
                                  width: 28,
                                  margin: EdgeInsets.only(right: 10)),
                              Text(account.name)
                            ],
                          ),
                    trailing: Text(account.balance.toStringAsFixed(2),
                        style: account.balance >= 0
                            ? TextStyle(color: Colors.green[600])
                            : TextStyle(color: Colors.red[600])),
                  )),
            ),
          ],
        );
      }).toList();
    }

    return Scaffold(
        appBar: AppBar(title: Text(localizer.account), actions: <Widget>[
          PopupMenuButton(
              icon: Icon(Icons.menu),
              initialValue: '',
              onSelected: (String value) {
                switch (value) {
                  case 'createAccount':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                AccountEditScreen())).then((res) {
                      updateAccountsList();
                    });
                    break;
                  case 'transfer':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                AccountTransferScreen())).then((res) {
                      updateAccountsList();
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                        value: 'createAccount',
                        child: Text(localizer.createAccount)),
                    PopupMenuItem<String>(
                        value: 'transfer', child: Text(localizer.transfer)),
                  ])
        ]),
        body: ListView(
          children: [
            ...renderAccounts(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                      'Total: ${accounts.length > 0 ? accounts.map((account) => account.balance).reduce((value, element) => value + element).toStringAsFixed(2) : ''}')
                ],
              ),
            )
          ],
        ));
  }
}
