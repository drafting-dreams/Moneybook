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
  DateTime date = DateTime.now();
  String _selectedType;
  DateTime _repeatDate = DateTime.now();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _repeatTimeController = TextEditingController();

  initState() {
    super.initState();
    _frequencyController.text = '1';
    _repeatTimeController.text = '2';
    // if today is after 28, then _repeatDate will be next month's first day
    if (_repeatDate.day > 28) {
      if (_repeatDate.month < 12) {
        _repeatDate = DateTime(_repeatDate.year, _repeatDate.month + 1, 1);
      } else {
        _repeatDate = DateTime(_repeatDate.year + 1, 1, 1);
      }
    }
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: date != null ? date : DateTime.now(),
        firstDate: DateTime(2019),
        lastDate: DateTime(DateTime.now().year + 70));
    if (picked != null) {
      final DateTime today = DateTime.now();
      // bill date should be before today and can't be today !!!
      if (picked.compareTo(today) < 0 &&
          (!(picked.year == today.year &&
              picked.month == today.month &&
              picked.day == today.day))) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                    title: Text('Inappropriate Bill Date'),
                    content: Text('Bill date should be on or after today.'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _selectDate();
                          },
                          child: Text('OK'))
                    ]));
      } else {
        setState(() {
          date = picked;
        });
      }
    }
  }

  Future _selectRepeatDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: _repeatDate != null ? _repeatDate : DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(DateTime.now().year + 70));
    if (picked != null) {
      final DateTime today = DateTime.now();
      // bill date should be before today and can't be today !!!
      if (picked.compareTo(today) < 0 &&
        (!(picked.year == today.year &&
          picked.month == today.month &&
          picked.day == today.day))) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Inappropriate Bill Date'),
            content: Text('Bill date should be on or after today.'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectDate();
                },
                child: Text('OK'))
            ]));
      } else if (picked.day > 28) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Inappropriate Bill Date'),
            content: Text('Repeat Bill day should be on or before 28 of each month.'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectRepeatDate();
                },
                child: Text('OK'))
            ]));
      } else {
        setState(() {
          _repeatDate = picked;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    var typeInfo = Provider.of<ExpenseTypeInfo>(context);
    if (_selectedType == null) {
      setState(() {
        _selectedType = typeInfo.types[0].name;
      });
    }

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
                  ExpandedSection(
                    expand: !_repeat,
                    child: InkWell(
                        onTap: _selectDate,
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Icon(
                                    Icons.date_range,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                        '${date.year}-${date.month}-${date.day}',
                                        style: TextStyle(fontSize: 16)))
                              ],
                            ))),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left:35.0),
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
                                      labelText: 'Repeat Frequency By Month'),
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
                          InkWell(
                            onTap: _selectRepeatDate,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Icon(
                                      Icons.date_range,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${_repeatDate.year}-${_repeatDate.month}-${_repeatDate.day}',
                                      style: TextStyle(fontSize: 16)))
                                ],
                              )))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
