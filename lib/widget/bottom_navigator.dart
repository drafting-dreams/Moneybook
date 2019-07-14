import 'package:flutter/material.dart';
import 'package:money_book/widget/no_animation_route.dart';
import 'package:money_book/screens/setting_screen.dart';
import 'package:money_book/screens/book_screen.dart';

class BottomNavigator extends StatelessWidget {
  final int initialIndex;

  BottomNavigator({this.initialIndex});

  Function tapWrapper(BuildContext context) {
    void _onItemTapped(int index) {
      if (index != initialIndex) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) => BookScreen()));
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) => SettingScreen()));
            break;
          default:
        }
      }
    }

    return _onItemTapped;
  }

  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('History')),
        BottomNavigationBarItem(
            icon: Icon(Icons.equalizer), title: Text('Statistic')),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), title: Text('Settings'))
      ],
      currentIndex: initialIndex,
      onTap: tapWrapper(context),
    );
  }
}
