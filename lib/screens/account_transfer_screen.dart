import 'package:flutter/material.dart';
import 'package:money_book/locale/locales.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/model/expense_type.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/widget/simple_information_dialog.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/api/transaction.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';

class AccountTransferScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountTransferScreen();
  }
}

class _AccountTransferScreen extends State<AccountTransferScreen> {
  final _amountController = TextEditingController();
  Account from;
  Account to;
  final _formKey = GlobalKey<FormState>();
  List<Account> accounts = [];

  void initState() {
    super.initState();
    AccountAPI.getAll().then((List<Account> all) {
      setState(() {
        this.accounts = all;
      });
    });
  }

  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void handleClickTransfer() {}

  @override
  Widget build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    var accountState = Provider.of<AccountState>(context);
    var typeInfo = Provider.of<ExpenseTypeInfo>(context);
    final localizer = AppLocalizations.of(context);
    final dropDownItems = accounts
      .map((Account account) =>
      DropdownMenuItem<Account>(
        value: account,
        child: Row(
          children: <Widget>[Text(account.name)],
        )))
      .toList();
    return Scaffold(
      appBar: AppBar(title: Text(localizer.transfer)),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('${localizer.fromAccount}: '),
                ),
                Expanded(
                  child: DropdownButton<Account>(
                    isExpanded: true,
                    value: this.from,
                    onChanged: (Account value) {
                      setState(() {
                        this.from = value;
                      });
                    },
                    items: dropDownItems)),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('${localizer.toAccount}: '),
                ),
                Expanded(
                  child: DropdownButton<Account>(
                    isExpanded: true,
                    value: this.to,
                    onChanged: (Account value) {
                      setState(() {
                        this.to = value;
                      });
                    },
                    items: dropDownItems),
                )
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: localizer.amount),
              controller: _amountController,
              keyboardType: TextInputType.number,
              validator: (v) {
                String value = _amountController.text;
                if (value.isEmpty) {
                  return localizer.enterTransferAmount;
                }
                if (!Util.isNumeric(value) || double.parse(value) <= 0) {
                  return localizer.enterPositive;
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          if (from.id == to.id) {
                            showSimpleDialog(context, localizer.sameAccount,
                              localizer.sameAccountContent);
                          } else {
                            final types = await ExpenseTypeAPI.list();
                            if (!types.any((type) =>
                            type.name == localizer.transfer)) {
                              await ExpenseTypeAPI.createType(
                                localizer.transfer,
                                'IconData(U+0E227)',
                                'MaterialColor(primary value: Color(0xffffeb3b))');
                              typeInfo.add(ExpenseType(
                                localizer.transfer, 'IconData(U+0E227)',
                                'MaterialColor(primary value: Color(0xffffeb3b))'));
                            }
                            Transaction transferFrom = Transaction(
                              -double.parse(_amountController.text),
                              DateTime.now(),
                              from.id,
                              type: localizer.transfer,
                              name:
                              "${localizer.transferTo} ${localizer
                                .account} '${to.name}'");
                            Transaction transferTo = Transaction(
                              double.parse(_amountController.text),
                              DateTime.now(),
                              to.id,
                              type: localizer.transfer,
                              name:
                              "${localizer.transferFrom} ${localizer
                                .account} '${from.name}'");
                            await TransactionAPI.add(transferFrom);
                            await TransactionAPI.add(transferTo);
                            if (accountState.currentAccount.id ==
                              from.id) {
                              transactions.add(transferFrom);
                            }
                            if (accountState.currentAccount.id ==
                              to.id) {
                              transactions.add(transferTo);
                            }
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                      color: Theme
                        .of(context)
                        .accentColor,
                      child: Text(
                        '${localizer.confirm} ${localizer.transfer}')),
                  ),
                ),
              ],
            )
          ]),
        ),
      ));
  }
}
