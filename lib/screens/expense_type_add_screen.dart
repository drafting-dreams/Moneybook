import 'package:flutter/material.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/const/icons.dart';

class ExpenseTypeAddScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseTypeAddScreen();
  }
}

class _ExpenseTypeAddScreen extends State<ExpenseTypeAddScreen> {
  List<String> types = [];
  IconData selectedIcon = Icons.business;
  Color selectedColor = Colors.indigoAccent;
  final _textController = TextEditingController();

  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    ExpenseTypeAPI.list().then((data) {
      setState(() {
        types = data;
      });
    });
  }

  List<Widget> _build() {
    final List<Widget> re = [];
    icons.forEach((k, v) {
      re.add(_buildBlock(k, v));
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Expense Type'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                print(selectedColor);
                print(selectedIcon);
                print(_textController.text);
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
                    children: _build(),
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
                      border:
                          Border(bottom: BorderSide(width: 0.3, color: Colors.grey))),
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
                        padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(hintText: 'Type name'),
                        ),
                      ))
                    ],
                  ),
                )),
          ],
        ));
  }
}
