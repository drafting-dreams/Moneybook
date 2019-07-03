import 'package:money_book/model/account.dart';
import 'package:money_book/localDB/database_creator.dart';

class AccountService {
  static Future<List<Account>> getAll() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.accountTable}''';
    final data = await db.rawQuery(sql);
    List<Account> accounts = List();

    for (final node in data) {
      final account = Account.fromJson(node);
      accounts.add(account);
    }
    return accounts;
  }

  static Future<Account> getUsingAccount() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.accountTable}
    WHERE ${DatabaseCreator.accountUsing} = 1''';

    final data = await db.rawQuery(sql);

    return Account.fromJson(data[0]);
  }

  static Future<Account> getAccountById(String id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.accountTable}
    WHERE ${DatabaseCreator.accountId} = ?''';

    List<dynamic> params= [id];
    final data = await db.rawQuery(sql, params);

    return Account.fromJson(data[0]);
  }

  static Future<Account> createAccount(Account account) async {
    final sql = '''INSERT INTO ${DatabaseCreator.accountTable}
    (
      ${DatabaseCreator.accountId},
      ${DatabaseCreator.accountName},
      ${DatabaseCreator.accountBalance},
      ${DatabaseCreator.accountUsing}
    )
    VALUES(?,?,?,?)''';
    List<dynamic> params = [account.id, account.name, account.balance, 0];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog(
        'Created an new account', sql, null, result, params);

    return account;
  }

  static Future<void> updateAccount(String id, String name, double balance) async {
    final sql = '''UPDATE ${DatabaseCreator.accountTable}
    SET ${DatabaseCreator.accountName} = ?,
        ${DatabaseCreator.accountBalance} = ?
    WHERE ${DatabaseCreator.accountId} = ?''';

    List<dynamic> params = [name, balance, id];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Update account', sql, null, result, params);
  }

  static Future<void> deleteAccount(String id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.accountTable}
    WHERE ${DatabaseCreator.accountId} = ?''';
    List<dynamic> params = [id];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete Account', sql, null, null, params);
  }

  static Future<void> setCurrent(String id) async {
    final sql1 = '''UPDATE ${DatabaseCreator.accountTable}
    SET ${DatabaseCreator.accountUsing} = 0
    WHERE ${DatabaseCreator.accountUsing} != 0''';
    final sql2 = '''UPDATE ${DatabaseCreator.accountTable}
    SET ${DatabaseCreator.accountUsing} = 1
    WHERE ${DatabaseCreator.accountId} = ?''';
    await db.rawUpdate(sql1);
    List<dynamic> params = [id];
    final result = await db.rawUpdate(sql2, params);
    DatabaseCreator.databaseLog(
        'Set current account', sql2, null, result, params);
  }
}
