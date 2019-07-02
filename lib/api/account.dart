import 'package:money_book/model/account.dart';
import 'package:money_book/localDB/service/account.dart';

class AccountAPI {
  static Future<Account> getCurrentAccount() async {
    Account account = await AccountService.getUsingAccount();
    return account;
  }

  static Future<List<Account>> getAll() async {
    List<Account> accounts = await AccountService.getAll();
    return accounts;
  }
}