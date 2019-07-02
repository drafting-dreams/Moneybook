import 'package:flutter/foundation.dart';
import 'package:money_book/model/account.dart';

class AccountState extends ChangeNotifier {
  Account currentAccount;

  AccountState();

  setCurrentAccount(Account account) {
    this.currentAccount = account;
  }
}