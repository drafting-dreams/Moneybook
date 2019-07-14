import 'package:flutter/material.dart';
import 'package:money_book/widget/no_animation_route.dart';
import 'package:money_book/screens/account_screen.dart';
import 'package:money_book/widget/bottom_navigator.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      bottomNavigationBar: BottomNavigator(
        initialIndex: 2,
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (BuildContext context) => AccountScreen()));
              },
              child: ListTile(
                  title: Row(
                children: <Widget>[
                  Container(
                      width: 28,
                      margin: EdgeInsets.only(right: 20),
                      child: Icon(Icons.account_box, color: Theme.of(context).accentColor,)),
                  Text('Account',)
                ],
              ), trailing: Icon(Icons.chevron_right),))
        ],
      ),
    );
  }
}
