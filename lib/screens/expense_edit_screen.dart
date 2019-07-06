import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/api/transaction.dart';

class ExpenseEditScreen extends StatefulWidget {
  String id;

  ExpenseEditScreen({this.id});

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
  ExpenseType selectedType = ExpenseType.food;

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
        initialDate: DateTime.now(),
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

    return Scaffold(
        appBar: AppBar(title: Text('Moneybook'), actions: [
          FlatButton(
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
                  transactions.add(t);
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
            child: Text('Save'),
            textColor: Colors.white,
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
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Amount'),
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
                        TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Description'),
                            controller: descriptionController,
                            validator: (v) {
                              String value = descriptionController.text;
                              if (value.trim().isEmpty) {
                                return 'Please input some description about the income';
                              }
                            }),
                        DropdownButton<ExpenseType>(
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.food,
                                child: Text(
                                    Util.expenseType2String(ExpenseType.food))),
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.housing,
                                child: Text(Util.expenseType2String(
                                    ExpenseType.housing))),
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.entertainment,
                                child: Text(Util.expenseType2String(
                                    ExpenseType.entertainment))),
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.communication,
                                child: Text(Util.expenseType2String(
                                    ExpenseType.communication))),
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.cloth,
                                child: Text(Util.expenseType2String(
                                    ExpenseType.cloth))),
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.electronic,
                                child: Text(Util.expenseType2String(
                                    ExpenseType.electronic))),
                            DropdownMenuItem<ExpenseType>(
                                value: ExpenseType.others,
                                child: Text(Util.expenseType2String(
                                    ExpenseType.others))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                            });
                          },
                          value: selectedType,
                        ),
                      ],
                    )),
                InkWell(
                  onTap: _selectDate,
                  child: ListTile(
                      title: Text('${date.year}-${date.month}-${date.day}')),
                )
              ],
            ))));
  }
}
