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

  String get transactionClass =>
      Intl.message('Class', name: 'transactionClass');

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

  String get repeatFrequency =>
      Intl.message('Repeat Frequency By Month', name: 'repeatFrequency');

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

  String get paymentStatus =>
      Intl.message('Payment Status', name: 'paymentStatus');

  String get paid => Intl.message('Paid', name: 'paid');

  String get unpaid => Intl.message('Unpaid', name: 'unpaid');

  String get chartWarn =>
      Intl.message('No data for this period of time', name: 'chartWarn');

  String get seven => Intl.message('recent 7 days', name: 'seven');

  String get thirty => Intl.message('recent 30 days', name: 'thirty');

  String get lastSix => Intl.message('last 6 months', name: 'lastSix');

  String get edit => Intl.message('Edit', name: 'edit');

  String get delete => Intl.message('Delete', name: 'delete');

  String get pay => Intl.message('Pay', name: 'pay');

  String get ratioChart =>
      Intl.message('Expense type ratio chart', name: 'ratioChart');

  String get trendChart =>
      Intl.message('Expense trend chart', name: 'trendChart');

  String get account => Intl.message('Account', name: 'account');

  String get typeName => Intl.message('Type Name', name: 'typeName');

  String get housing => Intl.message('Housing', name: 'housing');

  String get commuting => Intl.message('Commuting', name: 'commuting');

  String get food => Intl.message('Food', name: 'food');

  String get shopping => Intl.message('Shopping', name: 'shopping');

  String get digital => Intl.message('Digital', name: 'digital');

  String get individual => Intl.message('Individual', name: 'individual');

  String get education => Intl.message('Education', name: 'education');

  String get entertainment =>
      Intl.message('Entertainment', name: 'entertainment');

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

  String get enterExpenseAmount =>
      Intl.message('Please enter your expense amount',
          name: 'enterExpenseAmount');

  String get enterIncomeAmount =>
      Intl.message('Please enter your income amount',
          name: 'enterIncomeAmount');

  String get enterBillAmount =>
      Intl.message('Please enter your bill amount for each period',
          name: 'enterBillAmount');

  String get enterPositive =>
      Intl.message('Please enter a positive Number', name: 'enterPositive');

  String get incomeDescription =>
      Intl.message('Please input some description about the income',
          name: 'incomeDescription');

  String get expenseDescription =>
      Intl.message('Please input some description about the expense',
          name: 'expenseDescription');

  String get billDescription =>
      Intl.message('Please input some description about the bill',
          name: 'billDescription');

  String get frequencyRange =>
      Intl.message('Please enter an integer ranged from 1 to 60',
          name: 'frequencyRange');

  String get repeatTimesRange =>
      Intl.message('Please enter an integer ranged from 2 to 60',
          name: 'repeatTimesRange');

  String get createAccount =>
      Intl.message('Create Account', name: 'createAccount');

  String get accountName => Intl.message('Account Name', name: 'accountName');

  String get accountBalance =>
      Intl.message('Account Balance', name: 'accountBalance');

  String get inputAccountName =>
      Intl.message("Please input account's name", name: 'inputAccountName');

  String get enterAccountBalance =>
      Intl.message("Please enter account's balance",
          name: 'enterAccountBalance');

  String get invalidNumber =>
      Intl.message('Invalid number', name: 'invalidNumber');

  String get deleteAccount =>
      Intl.message('Delete Account', name: 'deleteAccount');

  String get bigDelete => Intl.message('DELETE', name: 'bigDelete');

  String get confirmDeleteAccount => Intl.message(
      'All related information including transactions and bills will be deleted, are you sure?',
      name: 'confirmDeleteAccount');

  String get ok => Intl.message('OK', name: 'ok');

  String get oneType =>
      Intl.message('There must be at least one expense type.', name: 'oneType');

  String get maximumType =>
      Intl.message('The maximum number of expense type is 11.',
          name: 'maximumType');

  String get typeNumberLimit =>
      Intl.message('Types number limit', name: 'typeNumberLimit');

  String get addExpenseType =>
      Intl.message('Add Expense Type', name: 'addExpenseType');

  String get cancel => Intl.message('CANCEL', name: 'cancel');

  String get deleteType => Intl.message('Delete Type', name: 'deleteType');

  String get confirmDeleteType1 =>
      Intl.message('This will delete the ', name: 'confirmDeleteType1');

  String get confirmDeleteType2 => Intl.message(
      ' type, all related transactions and bills on all accounts!\n\nAre you sure?',
      name: 'confirmDeleteType2');

  String get wrongName => Intl.message('Wrong name', name: 'wrongName');
  String get enterTypeName => Intl.message('Please enter a name', name: 'enterTypeName');
  String get backupSuccess => Intl.message('Backup Success', name: 'backupSuccess');
  String get backupMessage => Intl.message('Backup file was saved at ', name: 'backupMessage');
  String get confirmImport => Intl.message('This will wipe all your current data on you device. Are you sure?', name: 'confirmImport');
  String get yes => Intl.message('Yes', name: 'yes');
  String get no => Intl.message('No', name: 'no');
  String get importFailed => Intl.message('Read File Failed', name: 'importFailed');
  String get importFailedMessage1 => Intl.message('Make sure this file (', name: 'importFailedMessage1');
  String get importFailedMessage2 => Intl.message('/.moneybookbackup) exist on you device.', name: 'importFailedMessage2');
  String get importSuccess => Intl.message('Import Success', name: 'importSuccess');
  String get importSuccessMessage => Intl.message('Backup data is imported successfully', name: 'importSuccessMessage');
  String get autoPayNotification => Intl.message('Autopay Notification', name: 'autoPayNotification');
  String get autoPayNotificationMessage => Intl.message('Autopay bills has been paid.', name: 'autoPayNotificationMessage');
  String get gotIt => Intl.message('Got it', name: 'gotIt');
  String get deleteTransaction => Intl.message('Delete Transaction', name: 'deleteTransaction');
  String get confirmDeleteTransaction => Intl.message("Do you want this operation affect your account's balance?", name: 'confirmDeleteTransaction');
  String get todaysPaid => Intl.message("Today's bill has been successfully paid!", name: 'todaysPaid');
  String get billPaid => Intl.message('The bill has been successfully paid.', name: 'billPaid');
  String get deleteBill => Intl.message('Delete Bill', name: 'deleteBill');
  String get deleteBillMessage => Intl.message('Delete this bill record.', name: 'deleteBillMessage');
  String get payBill => Intl.message('Pay Bill', name: 'payBill');
  String get payBillMessage => Intl.message('Are you sure you wanna pay this bill TODAY?', name: 'payBillMessage');
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
