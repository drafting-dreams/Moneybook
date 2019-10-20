import 'package:flutter/material.dart';
import 'package:money_book/api/keeper.dart';
import 'package:money_book/app.dart';
import 'package:money_book/model/transaction.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:provider/provider.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/model/expense_type.dart';
import 'package:money_book/widget/expanded_section.dart';
import 'package:money_book/model/bill.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/api/bill.dart';
import 'package:money_book/locale/locales.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_book/utils/util.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class BillEditScreen extends StatefulWidget {
  String id;

  BillEditScreen({this.id});

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
  final _frequencyFocusNode = FocusNode();
  final _repeatFocusNode = FocusNode();
  Bill previousBill;

  initState() {
    super.initState();
    _frequencyController.text = '1';
    _repeatTimeController.text = '2';
    _frequencyFocusNode.addListener(_onFrequencyFocus);
    _repeatFocusNode.addListener(_onRepeatFocus);
    // if today is after 28, then _repeatDate will be next month's first day
    if (_repeatDate.day > 28) {
      if (_repeatDate.month < 12) {
        _repeatDate = DateTime(_repeatDate.year, _repeatDate.month + 1, 1);
      } else {
        _repeatDate = DateTime(_repeatDate.year + 1, 1, 1);
      }
    }

    if (widget.id != null) {
      BillAPI.getBillById(widget.id).then((Bill bill) {
        setState(() {
          previousBill = bill;
          _amountController.text = (-bill.value).toString();
          _descriptionController.text = bill.name;
          date = bill.dueDate;
          _selectedType = bill.type;
          _autoPay = bill.autoPay;
        });
      });
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _setSchedualedNotification(
      int id, DateTime schedualedTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'money_book_id', 'money_book', 'money book bill notification channel',
        ongoing: false, autoCancel: true);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        id,
        'MoneyBook',
        'You have unpaid bills today.',
        schedualedTime,
        platformChannelSpecifics);
  }

  _onFrequencyFocus() {
    if (_frequencyFocusNode.hasFocus) {
      _frequencyController.selection = TextSelection(
          baseOffset: 0, extentOffset: _frequencyController.text.length);
    }
  }

  _onRepeatFocus() {
    if (_repeatFocusNode.hasFocus) {
      _repeatTimeController.selection = TextSelection(
          baseOffset: 0, extentOffset: _repeatTimeController.text.length);
    }
  }

  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    _repeatTimeController.dispose();
    _frequencyFocusNode.removeListener(_onFrequencyFocus);
    _repeatFocusNode.removeListener(_onRepeatFocus);
    _frequencyFocusNode.dispose();
    _repeatFocusNode.dispose();
    super.dispose();
  }

  Future _selectDate(BuildContext context) async {
    var localizer = AppLocalizations.of(context);
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
                    title: Text(localizer.inappropriateBillDate),
                    content: Text(localizer.dateOnOrAfter),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(localizer.ok))
                    ]));
      } else {
        setState(() {
          date = picked;
        });
      }
    }
  }

  Future _selectRepeatDate(BuildContext context) async {
    final localizer = AppLocalizations.of(context);
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
                    title: Text(localizer.inappropriateBillDate),
                    content: Text(localizer.dateOnOrAfter),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(localizer.ok))
                    ]));
      } else if (picked.day > 28) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                    title: Text(localizer.inappropriateBillDate),
                    content: Text(localizer.repeatBillWarning),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(localizer.ok))
                    ]));
      } else {
        setState(() {
          _repeatDate = picked;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    var accountState = Provider.of<AccountState>(context);
    var typeInfo = Provider.of<ExpenseTypeInfo>(context);
    var transactions = Provider.of<Transactions>(context);
    var localizer = AppLocalizations.of(context);

    if (_selectedType == null) {
      setState(() {
        _selectedType = typeInfo.types[0].name;
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(localizer.bill),
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    bool paidToday = false;
                    if (widget.id == null) {
                      if (_repeat) {
                        int notificationId;
                        for (int i = 0;
                            i < int.parse(_repeatTimeController.text);
                            i++) {
                          int addedMonth = _repeatDate.month +
                              i * int.parse(_frequencyController.text);
                          int yearToBeAdd = 0;
                          int newMonth = 0;
                          if (addedMonth > 12) {
                            yearToBeAdd = (addedMonth / 12).floor();
                            newMonth = addedMonth % 12;
                          } else {
                            newMonth = addedMonth;
                          }
                          DateTime billDate = DateTime(
                              _repeatDate.year + yearToBeAdd,
                              newMonth,
                              _repeatDate.day);
                          if (!_autoPay) {
                            if (!Util.isTheSameDay(billDate, DateTime.now())) {
                              notificationId =
                                  await KeeperAPI.checkAndUpdateKeeper(1);
                              await _setSchedualedNotification(notificationId,
                                  billDate.add(Duration(hours: 8)));
                            } else {
                              if (billDate.hour < 20) {
                                notificationId =
                                    await KeeperAPI.checkAndUpdateKeeper(1);
                                await _setSchedualedNotification(
                                    notificationId,
                                    DateTime(billDate.year, billDate.month,
                                        billDate.day, 20));
                              }
                            }
                          }
                          Bill bill = Bill(
                              -double.parse(_amountController.text),
                              billDate,
                              accountState.currentAccount.id,
                              _selectedType,
                              _autoPay,
                              false,
                              name: _descriptionController.text,
                              notificationId: notificationId);
                          await BillAPI.add(bill);
                          if (i == 0 &&
                              bill.autoPay &&
                              Util.isTheSameDay(DateTime.now(), bill.dueDate)) {
                            Transaction t = Transaction(
                                bill.value, DateTime.now(), bill.accountId,
                                type: bill.type, name: bill.name);
                            await BillAPI.pay(bill.id, t);
                            transactions.add(t);
                            paidToday = true;
                          }
                        }
                      } else {
                        int notificationId;
                        if (!_autoPay) {
                          if (!Util.isTheSameDay(date, DateTime.now())) {
                            notificationId =
                            await KeeperAPI.checkAndUpdateKeeper(1);
                            await _setSchedualedNotification(
                                notificationId, date.add(Duration(hours: 8)));
                          } else {
                            if (date.hour < 20) {
                              notificationId =
                              await KeeperAPI.checkAndUpdateKeeper(1);
                              await _setSchedualedNotification(
                                  notificationId,
                                  DateTime(
                                      date.year, date.month, date.day, 20));
                            }
                          }
                        }
                        Bill bill = Bill(
                            -double.parse(_amountController.text),
                            date,
                            accountState.currentAccount.id,
                            _selectedType,
                            _autoPay,
                            false,
                            name: _descriptionController.text,
                            notificationId: notificationId);
                        await BillAPI.add(bill);
                        if (bill.autoPay &&
                            Util.isTheSameDay(DateTime.now(), bill.dueDate)) {
                          Transaction t = Transaction(
                              bill.value, DateTime.now(), bill.accountId,
                              type: bill.type, name: bill.name);
                          await BillAPI.pay(bill.id, t);
                          transactions.add(t);
                          paidToday = true;
                        }
                      }
                    } else {
                      if (!Util.isTheSameDay(previousBill.dueDate, date) && previousBill.notificationId != null) {
                        flutterLocalNotificationsPlugin.cancel(previousBill.notificationId);
                      }
                      int notificationId;
                      if (!_autoPay) {
                        if (!Util.isTheSameDay(date, DateTime.now())) {
                          notificationId =
                          await KeeperAPI.checkAndUpdateKeeper(1);
                          await _setSchedualedNotification(
                            notificationId, date.add(Duration(hours: 8)));
                        } else {
                          if (date.hour < 20) {
                            notificationId =
                            await KeeperAPI.checkAndUpdateKeeper(1);
                            await _setSchedualedNotification(
                              notificationId,
                              DateTime(
                                date.year, date.month, date.day, 20));
                          }
                        }
                      }
                      Bill bill = Bill(
                          -double.parse(_amountController.text),
                          date,
                          accountState.currentAccount.id,
                          _selectedType,
                          _autoPay,
                          false,
                          name: _descriptionController.text,
                          notificationId: notificationId);
                      await BillAPI.modify(widget.id, bill);
                      if (bill.autoPay &&
                          Util.isTheSameDay(DateTime.now(), bill.dueDate)) {
                        Transaction t = Transaction(
                            bill.value, DateTime.now(), bill.accountId,
                            type: bill.type, name: bill.name);
                        await BillAPI.pay(widget.id, t);
                        transactions.add(t);
                        paidToday = true;
                      }
                    }
                    Navigator.of(context).pop(paidToday);
                  }
                },
                icon: Icon(Icons.check, color: Colors.white))
          ],
        ),
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
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          Expanded(
                              child: Text(localizer.autopay,
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
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: localizer.amount),
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            String value = _amountController.text;
                            if (value.isEmpty) {
                              return localizer.enterBillAmount;
                            }
                            if (!Util.isNumeric(value) ||
                                double.parse(value) <= 0) {
                              return localizer.enterPositive;
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
                            color: Theme.of(context).accentColor,
                          )),
                      Expanded(
                        child: TextFormField(
                            decoration: InputDecoration(
                                labelText: localizer.description),
                            controller: _descriptionController,
                            validator: (v) {
                              String value = _descriptionController.text;
                              if (value.trim().isEmpty) {
                                return localizer.billDescription;
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
                            color: Theme.of(context).accentColor),
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
                        onTap: () => _selectDate(context),
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Icon(
                                    Icons.date_range,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                        '${date.year}-${date.month}-${date.day}',
                                        style: TextStyle(fontSize: 16)))
                              ],
                            ))),
                  ),
                  widget.id != null
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Icon(
                                  Icons.repeat,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              Expanded(
                                  child: Text(localizer.repeat,
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
                    child: _repeat
                        ? Padding(
                            padding: const EdgeInsets.only(left: 35.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: Icon(
                                        Icons.av_timer,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            labelText:
                                                localizer.repeatFrequency),
                                        controller: _frequencyController,
                                        focusNode: _frequencyFocusNode,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          String value =
                                              _frequencyController.text;
                                          if (value.isEmpty ||
                                              !Util.isInt(value) ||
                                              int.parse(value) < 1 ||
                                              int.parse(value) > 60) {
                                            return localizer.frequencyRange;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: Icon(
                                        Icons.update,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            labelText: localizer.repeatTimes),
                                        controller: _repeatTimeController,
                                        focusNode: _repeatFocusNode,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          String value =
                                              _repeatTimeController.text;
                                          if (value.isEmpty ||
                                              !Util.isInt(value) ||
                                              int.parse(value) < 2 ||
                                              int.parse(value) > 60) {
                                            return localizer.repeatTimesRange;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                    onTap: () => _selectRepeatDate(context),
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 15),
                                              child: Icon(
                                                Icons.date_range,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                            Expanded(
                                                child: Text(
                                                    '${_repeatDate.year}-${_repeatDate.month}-${_repeatDate.day}',
                                                    style: TextStyle(
                                                        fontSize: 16)))
                                          ],
                                        )))
                              ],
                            ),
                          )
                        : Container(),
                  )
                ],
              ),
            )));
  }
}
