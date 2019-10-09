import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  String themeName = 'alien blue';
  ThemeData themeData = ThemeData.light();

  ThemeChanger([this.themeName, this.themeData]);

  getTheme() => themeData;

  setTheme(String name, ThemeData theme) {
    themeName = name;
    themeData = theme;
    notifyListeners();
  }
}