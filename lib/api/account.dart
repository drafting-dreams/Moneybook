import 'package:money_book/model/account.dart';
import 'package:money_book/localDB/service/account.dart';
import 'package:money_book/localDB/service/transaction.dart';

class AccountAPI {
  static Future<void> initializingAccount() async {
    final accounts = await getAll();
    if (accounts.length == 0) {
      final account = await AccountService.createAccount(Account('Normal'));
      await AccountService.setCurrent(account.id);
      print('First account initialized');
    }
  }

  static Future<Account> getCurrentAccount() async {
    Account account = await AccountService.getUsingAccount();
    return account;
  }

  static Future<void> setCurrentAccount(String id) async {
    await AccountService.setCurrent(id);
  }

  static Future<List<Account>> getAll() async {
    List<Account> accounts = await AccountService.getAll();
    return accounts;
  }

  static Future<void> createAccount(Account account) async {
    AccountService.createAccount(account);
  }

  static Future<void> deleteAccount(String id) async {
    await TransactionService.deleteTransactionsByAccount(id);
    await AccountService.deleteAccount(id);
  }
}