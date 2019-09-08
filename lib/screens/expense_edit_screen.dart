import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/expense_type.dart';

class ExpenseEditScreen extends StatefulWidget {
  String id;
  Function update;

  ExpenseEditScreen({this.id, this.update});

  @override
  State<StatefulWidget> createState() {
    return _ExpenseEdit();
  }
}

class _ExpenseEdit extends State<ExpenseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime date = DateTime.now();
  List<String> types = [];
  String selectedType;

  void initState() {
    super.initState();
    if (widget.id != null) {
      TransactionAPI.getTransactionById(widget.id)
          .then((Transaction transaction) {
        setState(() {
          amountController.text = (-transaction.value).toString();
          descriptionController.text = transaction.name;
          date = transaction.date;
          selectedType = transaction.type;
        });
      });
    }
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: date != null ? date : DateTime.now(),
        firstDate: DateTime(2019),
        lastDate: DateTime.now());
    if (picked != null)
      setState(() {
        date = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    var accountState = Provider.of<AccountState>(context);
    var typeInfo = Provider.of<ExpenseTypeInfo>(context);
    if (selectedType == null) {
      setState(() {
        selectedType = typeInfo.types[0].name;
      });
    }

    return Scaffold(
        appBar: AppBar(title: Text('Moneybook'), actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Transaction t = Transaction(
                    -double.parse(amountController.text),
                    date,
                    accountState.currentAccount.id,
                    type: selectedType,
                    name: descriptionController.text);
                if (widget.id == null) {
                  await TransactionAPI.add(t);
                  Transaction firstTransaction = transactions.get(0);
                  if (firstTransaction != null &&
                      (t.date.compareTo(firstTransaction.date) < 0 &&
                          (t.date.month != firstTransaction.date.month ||
                              t.date.year != firstTransaction.date.year))) {
                  } else {
                    transactions.add(t);
                  }
                  this.widget.update();
                } else {
                  await TransactionAPI.modify(widget.id, t);
                  transactions.update(widget.id, t);
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
        ]),
        body: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Container(
                child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Icon(
                                Icons.attach_money,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Amount'),
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  String value = amountController.text;
                                  if (value.isEmpty) {
                                    return 'Please enter your income amount';
                                  }
                                  if (!Util.isNumeric(value) ||
                                      double.parse(value) <= 0) {
                                    return 'Please enter a positive Number';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(right: 15),
                                child: Icon(
                                  Icons.subject,
                                  color: Theme.of(context).primaryColor,
                                )),
                            Expanded(
                              child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Description'),
                                  controller: descriptionController,
                                  validator: (v) {
                                    String value = descriptionController.text;
                                    if (value.trim().isEmpty) {
                                      return 'Please input some description about the income';
                                    }
                                  }),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Icon(Icons.category,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                items: typeInfo.types
                                    .map((ExpenseType type) =>
                                        DropdownMenuItem<String>(
                                            value: type.name,
                                            child: Row(
                                              children: <Widget>[
                                                RawMaterialButton(
                                                  constraints: BoxConstraints(
                                                      minWidth: 30,
                                                      minHeight: 30,
                                                      maxHeight: 45,
                                                      maxWidth: 45),
                                                  onPressed: () {},
                                                  shape: CircleBorder(),
                                                  child: Icon(type.icon,
                                                      color: Colors.white),
                                                  fillColor: type.color,
                                                ),
                                                Expanded(child: Text(type.name))
                                              ],
                                            )))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedType = value;
                                  });
                                },
                                value: selectedType,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                InkWell(
                  onTap: _selectDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(
                          Icons.date_range,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                          child: Text('${date.year}-${date.month}-${date.day}',
                              style: TextStyle(fontSize: 16)))
                    ]),
                  ),
                )
              ],
            ))));
  }
}
