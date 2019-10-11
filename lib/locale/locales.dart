import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:money_book/l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String get moneyBook => Intl.message('MoneyBook', name: 'moneyBook');
  String get statistic => Intl.message('Statistic', name: 'statistic');
  String get history => Intl.message('History', name: 'history');
  String get bill => Intl.message('Bill', name: 'bill');
  String get settings => Intl.message('Settings', name: 'settings');
  String get general => Intl.message('General', name: 'general');
  String get theme => Intl.message('Theme', name: 'theme');
  String get accounts => Intl.message('Accounts', name: 'accounts');
  String get expenseType => Intl.message('Expense Type', name: 'expenseType');
  String get backup => Intl.message('Backup', name: 'backup');
  String get import => Intl.message('Import Backup', name: 'import');
  String get transactionClass => Intl.message('Class', name: 'transactionClass');
  String get all => Intl.message('All', name: 'all');
  String get income => Intl.message('Income', name: 'income');
  String get expense => Intl.message('Expense', name: 'expense');
  String get time => Intl.message('Time', name: 'time');
  String get myDefault => Intl.message('Default', name: 'myDefault');
  String get byMonth => Intl.message('By Month', name: 'byMonth');
  String get byYear => Intl.message('By Year', name: 'byYear');
  String get customize => Intl.message('Customize', name: 'customize');
  String get amount => Intl.message('Amount', name: 'amount');
  String get description => Intl.message('Description', name: 'description');
  String get autopay => Intl.message('AutoPay', name: 'autopay');
  String get repeat => Intl.message('Repeat', name: 'repeat');
  String get repeatTimes => Intl.message('Repeat Times', name: 'repeatTimes');
  String get repeatFrequency => Intl.message('Repeat Frequency By Month', name: 'repeatFrequency');
  String get from => Intl.message('From', name: 'from');
  String get to => Intl.message('to', name: 'to');
  String get jan => Intl.message('Jan', name: 'jan');
  String get feb => Intl.message('Feb', name: 'feb');
  String get mar => Intl.message('Mar', name: 'mar');
  String get apr => Intl.message('Apr', name: 'apr');
  String get may => Intl.message('May', name: 'may');
  String get jun => Intl.message('Jun', name: 'jun');
  String get jul => Intl.message('Jul', name: 'jul');
  String get aug => Intl.message('Aug', name: 'aug');
  String get sep => Intl.message('Sep', name: 'sep');
  String get oct => Intl.message('Oct', name: 'oct');
  String get nov => Intl.message('Nov', name: 'nov');
  String get dec => Intl.message('Dec', name: 'dec');
  String get filterRange => Intl.message('Filter\nRange', name: 'filterRange');
  String get paymentStatus => Intl.message('Payment Status', name: 'paymentStatus');
  String get paid => Intl.message('Paid', name: 'paid');
  String get unpaid => Intl.message('Unpaid', name: 'unpaid');
  String get chartWarn => Intl.message('No data for this period of time', name: 'chartWarn');
  String get seven=> Intl.message('recent 7 days', name: 'seven');
  String get thirty => Intl.message('recent 30 days', name: 'thirty');
  String get lastSix => Intl.message('last 6 months', name: 'lastSix');
  String get edit => Intl.message('Edit', name: 'edit');
  String get delete => Intl.message('Delete', name: 'delete');
  String get pay => Intl.message('Pay', name: 'pay');
  String get ratioChart => Intl.message('Expense type ratio chart', name: 'ratioChart');
  String get trendChart => Intl.message('Expense trend chart', name: 'trendChart');
  String get account => Intl.message('Account', name: 'account');
  String get typeName => Intl.message('Type Name', name: 'typeName');
  String get housing => Intl.message('Housing', name: 'housing');
  String get commuting => Intl.message('Commuting', name: 'commuting');
  String get food => Intl.message('Food', name: 'food');
  String get shopping => Intl.message('Shopping', name: 'shopping');
  String get digital => Intl.message('Digital', name: 'digital');
  String get individual => Intl.message('Individual', name: 'individual');
  String get education => Intl.message('Education', name: 'education');
  String get entertainment => Intl.message('Entertainment', name: 'entertainment');
  String get exercising => Intl.message('Exercising', name: 'exercising');
  String get family => Intl.message('Family', name: 'family');
  String get medical => Intl.message('Medical', name: 'medical');
  String get others => Intl.message('Others', name: 'others');
  String get locally => Intl.message('Locally', name: 'locally');
  String get blue => Intl.message('Alien Blue', name: 'blue');
  String get green => Intl.message('Tree', name: 'green');
  String get pony => Intl.message('Pony', name: 'pony');
  String get purple => Intl.message('Noble Purple', name: 'purple');
  String get dark => Intl.message('Dark', name: 'dark');
  String get chocolate => Intl.message('Chocolate', name: 'chocolate');
  String get enterExpenseAmount => Intl.message('Please enter your expense amount', name: 'enterExpenseAmount');
  String get enterIncomeAmount => Intl.message('Please enter your income amount', name: 'enterIncomeAmount');
  String get enterBillAmount => Intl.message('Please enter your bill amount for each period', name: 'enterBillAmount');
  String get enterPositive => Intl.message('Please enter a positive Number', name: 'enterPositive');
  String get incomeDescription => Intl.message('Please input some description about the income', name: 'incomeDescription');
  String get expenseDescription => Intl.message('Please input some description about the expense', name: 'expenseDescription');
  String get billDescription => Intl.message('Please input some description about the bill', name: 'billDescription');
  String get frequencyRange => Intl.message('Please enter an integer ranged from 1 to 60', name: 'frequencyRange');
  String get repeatTimesRange => Intl.message('Please enter an integer ranged from 2 to 60', name: 'repeatTimesRange');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }

}
