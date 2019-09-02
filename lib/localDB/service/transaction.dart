import 'package:money_book/model/transaction.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/utils/util.dart';

class TransactionService {
  static Future<Transaction> getTransactionById(String id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.transactionId} = ?''';

    List<dynamic> params = [id];
    final transactions = await _executeSqlList(sql, params);
    return transactions[0];
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final sql = '''INSERT INTO ${DatabaseCreator.transactionTable}
    (
      ${DatabaseCreator.transactionId},
      ${DatabaseCreator.transactionName},
      ${DatabaseCreator.transactionValue},
      ${DatabaseCreator.transactionDate},
      ${DatabaseCreator.transactionType},
      ${DatabaseCreator.accountId}
    )
    VALUES(?,?,?,?,?,?)''';
    List<dynamic> params = [
      transaction.id,
      transaction.name,
      transaction.value,
      Util.date2DBString(transaction.date),
      transaction.type.toString(),
      transaction.accountId
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add Transaction', sql, null, result, params);
  }

  static Future<void> updateTransaction(
      String id, Transaction transaction) async {
    final sql = '''UPDATE ${DatabaseCreator.transactionTable}
    SET ${DatabaseCreator.transactionName} = ?,
    ${DatabaseCreator.transactionValue} = ?,
    ${DatabaseCreator.transactionDate} = ?,
    ${DatabaseCreator.transactionType} = ?
    WHERE ${DatabaseCreator.transactionId} = ?''';

    List<dynamic> params = [
      transaction.name,
      transaction.value,
      Util.date2DBString(transaction.date),
      transaction.type.toString(),
      id
    ];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog(
        'Update transaction', sql, null, result, params);
  }

  static Future<void> deleteTransactionById(String id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.transactionId} = ?''';

    List<dynamic> params = [id];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog(
        'Delete transaction by id', sql, null, null, params);
  }

  static Future<void> deleteTransactionsByAccount(String id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?''';
    List<dynamic> params = [id];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog(
        'Delete transaction by account', sql, null, null, params);
  }

  static Future<void> deleteTransactionsByType(String type) async {
    final sql = '''DELETE FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.transactionType} = ?''';
    List<dynamic> params = [type];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog(
      'Delete transaction by type', sql, null, null, params);
  }

  static Future<List<Transaction>> getAll(String accountId) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?
    ''';
    List<dynamic> params = [accountId];
    final re = await _executeSqlList(sql, params);
    return re;
  }

  static Future<List<Transaction>> getListByDate(
      String accountId, DateTime start,
      [DateTime end]) async {
    final s = Util.date2DBString(start);
    final e = Util.date2DBString(end);
    final sql = '''SELECT * FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.transactionDate} >= ?
    AND ${DatabaseCreator.transactionDate} <= ?
    ORDER BY ${DatabaseCreator.transactionDate} ASC
    ''';
    List<dynamic> params = [accountId, s, e];
    final re = await _executeSqlList(sql, params);
    return re;
  }

  static Future<double> getSumByDate(String accountId, DateTime start,
      DateTime end, TransactionClass tc) async {
    final s = Util.date2DBString(start);
    final e = Util.date2DBString(end);
    List<dynamic> params = [accountId, s, e];
    String sql;
    switch (tc) {
      case TransactionClass.expense:
        sql =
            '''SELECT SUM(${DatabaseCreator.transactionValue}) FROM ${DatabaseCreator.transactionTable}
        WHERE ${DatabaseCreator.accountId} = ?
        AND ${DatabaseCreator.transactionDate} >= ?
        AND ${DatabaseCreator.transactionDate} <= ?
        AND ${DatabaseCreator.transactionValue} < 0''';
        break;
      case TransactionClass.income:
        sql =
            '''SELECT SUM(${DatabaseCreator.transactionValue}) FROM ${DatabaseCreator.transactionTable}
        WHERE ${DatabaseCreator.accountId} = ?
        AND ${DatabaseCreator.transactionDate} >= ?
        AND ${DatabaseCreator.transactionDate} <= ?
        AND ${DatabaseCreator.transactionValue} > 0''';
        break;
      default:
        sql =
            '''SELECT SUM(${DatabaseCreator.transactionValue}) FROM ${DatabaseCreator.transactionTable}
        WHERE ${DatabaseCreator.accountId} = ?
        AND ${DatabaseCreator.transactionDate} >= ?
        AND ${DatabaseCreator.transactionDate} <= ?''';
    }
    final result = await db.rawQuery(sql, params);
    for (var i in result) {
      i.forEach((String key, dynamic value) {
        print(key);
      });
    }
    DatabaseCreator.databaseLog(
        'Get transaction sum', sql, result, null, params);
    return result[0]['SUM(${DatabaseCreator.transactionValue})'];
  }

  static Future<Map<String, double>> getSumByDateGroupByType(
      String accountId, DateTime start, DateTime end) async {
    final s = Util.date2DBString(start);
    final e = Util.date2DBString(end);
    List<dynamic> params = [accountId, s, e];
    final sql =
        '''SELECT ${DatabaseCreator.transactionType}, SUM(${DatabaseCreator.transactionValue})
    FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.transactionDate} >= ?
    AND ${DatabaseCreator.transactionDate} <= ?
    AND ${DatabaseCreator.transactionValue} < 0
    GROUP BY ${DatabaseCreator.transactionType}
    ''';
    final result = await db.rawQuery(sql, params);
    DatabaseCreator.databaseLog('GetSumByGroup', sql, result, null, params);
    Map<String, double> re = {};
    for (var item in result) {
      re[item[DatabaseCreator.transactionType]] =
          item['SUM(${DatabaseCreator.transactionValue})'];
    }
    return re;
  }

  static Future<DateTime> getNearestDate(
      String accountId, DateTime referenceDate) async {
    final previousMonthLastDay =
        DateTime(referenceDate.year, referenceDate.month, 0);
    final d = Util.date2DBString(previousMonthLastDay);
    final sql =
        '''SELECT ${DatabaseCreator.transactionDate} FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.transactionDate} <= ?
    ORDER BY ${DatabaseCreator.transactionDate} DESC LIMIT 1
    ''';
    List<dynamic> params = [accountId, d];
    final data = await db.rawQuery(sql, params);
    if (data.length < 1) {
      throw NoNearestDateException();
    }
    List<int> date =
        Util.dbString2date(data[0][DatabaseCreator.transactionDate]);
    return DateTime(date[0], date[1], date[2]);
  }

  static Future<int> getNearestYear(String accountId, int referenceYear) async {
    final d = Util.date2DBString(DateTime(referenceYear, 1, 1));
    final sql =
        ''' SELECT ${DatabaseCreator.transactionDate} FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.transactionDate} <= ?
    ORDER BY ${DatabaseCreator.transactionDate} DESC LIMIT 1
    ''';
    List<dynamic> params = [accountId, d];
    final data = await db.rawQuery(sql, params);
    if (data.length < 1) {
      throw NoNearestDateException();
    }
    return Util.dbString2date(data[0][DatabaseCreator.transactionDate])[0];
  }

  static Future<List<Transaction>> _executeSqlList(sql,
      [List<dynamic> params]) async {
    final data = await db.rawQuery(sql, params);
    List<Transaction> transactions = List();

    for (final node in data) {
      final transaction = Transaction.fromJson(node);
      transactions.add(transaction);
    }
    return transactions;
  }
}

class NoNearestDateException implements Exception {
  final String msg;

  const NoNearestDateException([this.msg]);

  String toString() => msg ?? 'No nearest date found';
}
