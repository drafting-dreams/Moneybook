import 'dart:async';

import 'package:flutter/material.dart';
import 'bottom_dialog.dart';

class RadioDialog<T> extends StatefulWidget {
  final String title;
  final Map<T, Widget> items;
  final T initialValue;

  RadioDialog(this.title, this.items, this.initialValue);

  @override
  _RadioDialogState<T> createState() => _RadioDialogState();
}

class _RadioDialogState<T> extends State<RadioDialog> {
  T _selectedValue;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedValue = this.widget.initialValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radioTiles = <Widget>[];
    this.widget.items.forEach((k, v) {
      radioTiles.add(RadioListTile(
        value: k,
        title: v,
        groupValue: _selectedValue,
        onChanged: (v) {
          setState(() {
            _selectedValue = v;
          });
          Timer(Duration(milliseconds: 200), () {
            Navigator.of(context).pop(v);
          });
        }));
    });
    return BottomDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.title, style: TextStyle(fontSize: 18),)),
            ),
            Divider(height: 2),
            ...radioTiles,
          ],
        ),
      ),
    );
  }
}

Future showRadioDialog(BuildContext context, String title, Map items,
  dynamic initialValue) =>
  showGeneralDialog(
    pageBuilder: (context, animation1, animation2) {},
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(.5),
    transitionDuration: Duration(milliseconds: 300),
    transitionBuilder: (context, animation1, animation2, child) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation1),
        child: RadioDialog(title, items, initialValue)));
