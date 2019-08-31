import 'package:flutter/material.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/api/account.dart';


class AccountEditScreen extends StatefulWidget {
  final String id;

  AccountEditScreen({this.id});

  State<StatefulWidget> createState() {
    return _AccountEditScreen();
  }
}

class _AccountEditScreen extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final nameController = TextEditingController();
  final balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      AccountAPI.getAccountById(widget.id).then((Account account) {
        setState(() {
          nameController.text = account.name;
          balanceController.text = account.balance.toString();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moneybook'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                if (widget.id == null) {
                  Account account = Account(nameController.text,
                    double.parse(balanceController.text));
                  await AccountAPI.createAccount(account);
                } else {
                  await AccountAPI.modifyAccount(widget.id, nameController.text,
                    double.parse(balanceController.text));
                }
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _autoValidate = true;
                });
              }
            },
            icon: Icon(Icons.check, color: Colors.white),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Account Name'),
                controller: nameController,
                validator: (v) {
                  String value = nameController.text;
                  if (value
                    .trim()
                    .isEmpty) {
                    return "Please input account's name";
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Account Balance'),
                controller: balanceController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  String value = balanceController.text;
                  if (value.isEmpty) {
                    return "Please enter account's balance";
                  }
                  if (!Util.isNumeric(value)) {
                    return 'Invalid number';
                  }
                })
            ],
          )),
      ));
  }
}
