import 'package:flutter/material.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/const/icons.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:provider/provider.dart';
import 'package:money_book/model/expense_type.dart';
import 'package:money_book/locale/locales.dart';

class ExpenseTypeAddScreen extends StatefulWidget {
  ExpenseType oldType;

  ExpenseTypeAddScreen([this.oldType]);

  @override
  State<StatefulWidget> createState() {
    return _ExpenseTypeAddScreen();
  }
}

class _ExpenseTypeAddScreen extends State<ExpenseTypeAddScreen> {
  IconData selectedIcon = Icons.business;
  Color selectedColor = Colors.indigoAccent;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.oldType != null) {
      _textController.text = widget.oldType.name;
      selectedIcon = widget.oldType.icon;
      selectedColor = widget.oldType.color;
    }
  }

  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void createOrModifyType(BuildContext context, ExpenseTypeInfo info,
      [String oldName = '']) {
    if (_textController.text.length < 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final localizer = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(localizer.wrongName),
            content: Text(localizer.enterTypeName),
            actions: <Widget>[
              FlatButton(
                child: Text(localizer.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else if (oldName == '' &&
        info.types.indexWhere((type) => type.name == _textController.text) >
            -1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final localizer = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(localizer.duplicatedName),
            content:
                Text('${localizer.duplicatedNameContent} ${_textController.text}.'),
            actions: <Widget>[
              FlatButton(
                child: Text(localizer.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else {
      if (oldName.length == 0) {
        ExpenseTypeAPI.createType(_textController.text, selectedIcon.toString(),
                selectedColor.toString())
            .then((void v) {
          info.add(ExpenseType(_textController.text, selectedIcon.toString(),
              selectedColor.toString()));
          Navigator.of(context).pop();
        });
      } else {
        ExpenseTypeAPI.modifyType(oldName, _textController.text,
                selectedIcon.toString(), selectedColor.toString())
            .then((void v) {
          info.update(
              oldName,
              ExpenseType(_textController.text, selectedIcon.toString(),
                  selectedColor.toString()));
          Navigator.of(context).pop();
        });
      }
    }
  }

  List<Widget> _build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    final List<Widget> re = [];
    icons.forEach((k, v) {
      re.add(
          _buildBlock(myLocale.languageCode.contains('zh') ? v['zh'] : k, v));
    });
    return re;
  }

  Widget _buildBlock(String title, Map iconInfo) {
    Color color = iconInfo['color'];
    List<IconData> icons = iconInfo['icons'];
    List<List<IconData>> groupByFour = [];

    for (int i = 0; i < icons.length; i += 4) {
      groupByFour
          .add(icons.sublist(i, i + 4 > icons.length ? icons.length : i + 4));
    }

    return Container(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      ...groupByFour.map((datas) => _buildIconRow(datas, color)).toList()
    ]));
  }

  Widget _buildIconRow(List<IconData> datas, Color color) {
    List<Widget> icons = datas
        .map((data) => Opacity(
            opacity: 1,
            child: RawMaterialButton(
              onPressed: () {
                setState(() {
                  selectedIcon = data;
                  selectedColor = color;
                });
              },
              constraints: BoxConstraints(minWidth: 45, minHeight: 45),
              shape: CircleBorder(),
              child: Icon(
                data,
                color: selectedIcon == data ? Colors.white : Colors.black54,
              ),
              fillColor: selectedIcon == data ? color : Colors.grey,
            )))
        .toList();
    int len = icons.length;
    if (icons.length < 4) {
      for (int i = 0; i < 4 - len; i++) {
        icons.add(Opacity(
            opacity: 0,
            child: RawMaterialButton(
              onPressed: () {},
              constraints: BoxConstraints(minWidth: 45, minHeight: 45),
              shape: CircleBorder(),
              child: Container(),
              fillColor: color,
            )));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: icons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var expenseTypeInfo = Provider.of<ExpenseTypeInfo>(context);
    final localizer = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(localizer.addExpenseType),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  createOrModifyType(context, expenseTypeInfo,
                      widget.oldType != null ? widget.oldType.name : '');
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ))
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              top: 60,
              bottom: 0,
              right: 0,
              left: 0,
              child: ListView(
                children: <Widget>[
                  Column(
                    children: _build(context),
                  )
                ],
              ),
            ),
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      border: Border(
                          bottom: BorderSide(width: 0.3, color: Colors.grey))),
                  child: Row(
                    children: <Widget>[
                      RawMaterialButton(
                          onPressed: () {},
                          constraints:
                              BoxConstraints(minWidth: 45, minHeight: 45),
                          shape: CircleBorder(),
                          child: Icon(
                            selectedIcon,
                            color: Colors.white,
                          ),
                          fillColor: selectedColor),
                      Expanded(
                          child: Padding(
                        padding:
                            const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                        child: TextField(
                            enabled: widget.oldType == null,
                            controller: _textController,
                            decoration:
                                InputDecoration(hintText: localizer.typeName),
                            style: widget.oldType == null
                                ? null
                                : TextStyle(color: Colors.grey)),
                      ))
                    ],
                  ),
                )),
          ],
        ));
  }
}
