import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/model/expense_type.dart';
import 'package:money_book/widget/expanded_section.dart';

class BillEditScreen extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _BillEditScreen();
  }
}

class _BillEditScreen extends State<BillEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _autoPay = true;
  bool _repeat = false;
  String _selectedType;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _repeatTimeController = TextEditingController();

  initState() {
    super.initState();
    _frequencyController.text = '1';
    _repeatTimeController.text = '2';
  }

  Widget build(BuildContext context) {
    var typeInfo = Provider.of<ExpenseTypeInfo>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Bill')),
        body: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Icon(
                              Icons.autorenew,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Expanded(
                              child: Text('AutoPay',
                                  style: TextStyle(fontSize: 16))),
                          Switch(
                            value: _autoPay,
                            onChanged: (bool newVal) {
                              setState(() {
                                _autoPay = newVal;
                              });
                            },
                          )
                        ],
                      )),
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
                          decoration: InputDecoration(labelText: 'Amount'),
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            String value = _amountController.text;
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
                            controller: _descriptionController,
                            validator: (v) {
                              String value = _descriptionController.text;
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
                              _selectedType = value;
                            });
                          },
                          value: _selectedType,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Icon(
                              Icons.repeat,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Expanded(
                              child: Text('Repeat',
                                  style: TextStyle(fontSize: 16))),
                          Switch(
                            value: _repeat,
                            onChanged: (bool newVal) {
                              setState(() {
                                _repeat = newVal;
                              });
                            },
                          )
                        ],
                      )),
                  ExpandedSection(
                    expand: _repeat,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Icon(
                                Icons.av_timer,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Repeat Frequency'),
                                controller: _frequencyController,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  String value = _frequencyController.text;
                                  if (value.isEmpty ||
                                      !Util.isInt(value) ||
                                      int.parse(value) < 1 ||
                                      int.parse(value) > 12) {
                                    return 'Please enter an integer ranged from 1 to 12';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Icon(
                                Icons.update,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Repeat Times'),
                                controller: _repeatTimeController,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  String value = _repeatTimeController.text;
                                  if (value.isEmpty ||
                                      !Util.isInt(value) ||
                                      int.parse(value) < 2 ||
                                      int.parse(value) > 60) {
                                    return 'Please enter an integer ranged from 3 to 60';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
