import 'package:flutter/material.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/screens/bill_edit_screen.dart';

class BillScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BillScreenState();
  }
}

class _BillScreenState extends State<BillScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => BillEditScreen()));
          }),
      body: Container(),
      bottomNavigationBar: BottomNavigator(initialIndex: 1),
    );
  }
}
