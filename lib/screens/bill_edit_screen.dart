import 'package:flutter/material.dart';

class BillEditScreen extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _BillEditScreen();
  }
}
 class _BillEditScreen extends State<BillEditScreen> {
   final _formKey = GlobalKey<FormState>();
   bool _autoValidate = false;
   bool _autoPay = false;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bill')),
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: <Widget>[
            SwitchListTile(value: _autoPay, onChanged: null)
          ],),
          )
        ],)
      )
    );
  }
 }