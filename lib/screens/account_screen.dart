import 'package:flutter/material.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/model/account.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountScreen();
  }
}

class _AccountScreen extends State<AccountScreen> {
  List<Account> accounts;

  void initState() {
    super.initState();
    AccountAPI.getAll().then((List<Account> all) {
      setState(() {
        this.accounts = all;
        print('initialized account list the length is' + this.accounts.length.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      bottomNavigationBar: BottomNavigator(
        initialIndex: 2,
      ),
//      body: ListView.builder()
    );
  }
}
