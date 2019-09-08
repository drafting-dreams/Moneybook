import 'package:flutter/material.dart';
import 'package:money_book/widget/no_animation_route.dart';
import 'package:money_book/screens/account_screen.dart';
import 'package:money_book/screens/expense_type_setting_screen.dart';
import 'package:money_book/widget/bottom_navigator.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen> {
  Widget renderTile(String text, IconData icon, Widget screen) =>
    InkWell(
      onTap: () {
        Navigator.push(
          context,
          NoAnimationMaterialPageRoute(
            builder: (BuildContext context) => screen));
      },
      child: ListTile(
        title: Row(
          children: <Widget>[
            Container(
              width: 28,
              margin: EdgeInsets.only(right: 20),
              child: Icon(icon, color: Theme
                .of(context)
                .accentColor,)),
            Text(text,)
          ],
        ),));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      bottomNavigationBar: BottomNavigator(
        initialIndex: 3,
      ),
      body: ListView(
        children: <Widget>[
          renderTile('Accounts', Icons.account_box, AccountScreen()),
          renderTile('Expense Type', Icons.category, ExpenseTypeSettingScreen())
        ],
      ),
    );
  }
}
