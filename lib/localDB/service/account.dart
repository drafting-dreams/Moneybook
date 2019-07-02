import 'package:money_book/model/account.dart';
import 'package:money_book/localDB/database_creator.dart';

class AccountService {
  static Future<void> initializingAccount() async {
    final accounts = await getAll();
    if (accounts.length == 0) {
      final account = await createAccount(Account('Normal'));
      await setCurrent(account.id);
      print('First account initialized');
    }
  }

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

  static Future<Account> createAccount(Account account) async {
    final sql = '''INSERT INTO ${DatabaseCreator.accountTable}
    (
      ${DatabaseCreator.accountId},
      ${DatabaseCreator.accountName},
      ${DatabaseCreator.accountUsing}
    )
    VALUES(?,?,?)''';
    List<dynamic> params = [account.id, account.name, 0];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog(
      'Created an new account', sql, null, result, params);

    return account;
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
