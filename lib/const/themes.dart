import 'package:flutter/material.dart';

final themes = {
  'alien blue': {
    'primary': Colors.lightBlue,
    'accent': Colors.lightBlueAccent,
    'divider': Colors.blue[100]
  },
  'tree': {
    'primary': Colors.greenAccent[700],
    'accent': Colors.greenAccent[400],
    'divider': Colors.greenAccent[100]
  },
  'pony': {
    'primary': Colors.pinkAccent,
    'accent': Colors.pinkAccent[100],
    'divider': Colors.deepOrange[100]
  },
  'noble purple': {
    'primary': Colors.purpleAccent[700],
    'accent': Colors.purpleAccent,
    'divider': Colors.purpleAccent[100]
  },
  'chocolate': {
    'primary': Colors.brown[800],
    'accent': Colors.brown[400],
    'divider': Colors.brown[200],
  }
};

ThemeData getTheme(String color) {
  if (color == 'dark') {
    final darkTheme = ThemeData.dark();
    return darkTheme.copyWith(
        cursorColor: darkTheme.accentColor,
        textSelectionHandleColor: darkTheme.accentColor);
  }

  final lightTheme = ThemeData.light();
  final colorScheme = lightTheme.colorScheme
    .copyWith(primary: themes[color]['primary'], secondary: themes[color]['accent']);

  return ThemeData.light().copyWith(
      colorScheme: colorScheme,
      buttonTheme: lightTheme.buttonTheme.copyWith(colorScheme: colorScheme),
      primaryColor: themes[color]['primary'],
      accentColor: themes[color]['accent'],
      dividerColor: themes[color]['divider'],
      cursorColor: themes[color]['accent'],
      textSelectionHandleColor: themes[color]['accent'],
      selectedRowColor: themes[color]['divider'],
      highlightColor: themes[color]['divider'],
      toggleableActiveColor: themes[color]['accent'],
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: themes[color]['primary']));
}
