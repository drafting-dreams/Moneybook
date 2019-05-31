import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/api/transaction.dart';

class IncomeEditScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IncomeEdit();
  }
}

class _IncomeEdit extends State<IncomeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime date = DateTime.now();

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

    return Scaffold(
        appBar: AppBar(title: Text('Moneybook'), actions: [
          FlatButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Transaction t = Transaction(
                    double.parse(amountController.text), date,
                    name: descriptionController.text);
                await TransactionAPI.add(t);
                transactions.add(t);
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
            textColor: Colors.white,
          )
        ]),
        body: Form(
            key: _formKey,
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
                            debugPrint(value);
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
