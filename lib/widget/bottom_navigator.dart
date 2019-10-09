import 'package:flutter/material.dart';
import 'package:money_book/widget/no_animation_route.dart';
import 'package:money_book/screens/setting_screen.dart';
import 'package:money_book/screens/book_screen.dart';
import 'package:money_book/screens/statistic_screen.dart';
import 'package:money_book/screens/bill_screen.dart';
import 'package:money_book/locale/locales.dart';

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
          case 1:
            Navigator.pushReplacement(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) => BillScreen()));
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) => StatisticScreen()));
            break;
          case 3:
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
//      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text(
              AppLocalizations.of(context).history,
            )),
        BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            title: Text(AppLocalizations.of(context).bill)),
        BottomNavigationBarItem(
            icon: Icon(Icons.equalizer),
            title: Text(AppLocalizations.of(context).statistic)),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).settings))
      ],
      selectedItemColor: Theme.of(context).accentColor,
      unselectedItemColor: Colors.grey,
      currentIndex: initialIndex,
      onTap: tapWrapper(context),
    );
  }
}
