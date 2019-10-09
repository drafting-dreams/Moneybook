import 'package:flutter/material.dart';
import 'package:money_book/screens/book_screen.dart';
import 'package:money_book/screens/income_edit_screen.dart';
import 'package:money_book/screens/expense_edit_screen.dart';
import 'package:money_book/screens/account_screen.dart';
import 'package:provider/provider.dart';
import 'package:money_book/shared_state/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'locale/locales.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    return MaterialApp(title: 'Moneybook', navigatorKey: navigatorKey,
      theme: themeChanger.getTheme(),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('zh', '')
      ],
      routes: {
      '/': (context) => BookScreen(),
      '/edit/income': (context) => IncomeEditScreen(),
      '/edit/expense': (context) => ExpenseEditScreen(),
      '/accounts': (context) => AccountScreen()
    });
  }

}