import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/utils/util.dart';

class TransactionService {
  static Future<void> addTransaction(Transaction transaction) async {
    final sql = '''INSERT INTO ${DatabaseCreator.transactionTable}
    (
      ${DatabaseCreator.transactionId},
      ${DatabaseCreator.transactionName},
      ${DatabaseCreator.transactionValue},
      ${DatabaseCreator.transactionDate},
      ${DatabaseCreator.transactionType}
    )
    VALUES(?,?,?,?,?)''';
    List<dynamic> params = [
      transaction.id,
      transaction.name,
      transaction.value,
      Util.date2DBString(transaction.date),
      transaction.type.toString()
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add Transaction', sql, null, result, params);
  }

  static Future<void> deleteTransactionsByAccount(String id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.accountId} = ?''';
    List<dynamic> params = [id];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog(
        'Delete transaction by account', sql, null, null, params);
  }

  static Future<List<Transaction>> getAll() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.transactionTable}
    ''';
    final re = await _executeSqlList(sql);
    return re;
  }

  static Future<List<Transaction>> getListByDate(DateTime start,
      [DateTime end]) async {
    final s = Util.date2DBString(start);
    final e = Util.date2DBString(end);
    final sql = '''SELECT * FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.transactionDate} >= ?
    AND ${DatabaseCreator.transactionDate} <= ?
    ORDER BY ${DatabaseCreator.transactionDate} ASC
    ''';
    List<dynamic> params = [s, e];
    final re = await _executeSqlList(sql, params);
    return re;
  }

  static Future<DateTime> getNearestDate(DateTime referenceDate) async {
    final previousMonthLastDay =
        DateTime(referenceDate.year, referenceDate.month, 0);
    final d = Util.date2DBString(previousMonthLastDay);
    final sql =
        '''SELECT ${DatabaseCreator.transactionDate} FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.transactionDate} <= ?
    ORDER BY ${DatabaseCreator.transactionDate} DESC LIMIT 1
    ''';
    List<dynamic> params = [d];
    final data = await db.rawQuery(sql, params);
    if (data.length < 1) {
      throw NoNearestDateException();
    }
    List<int> date =
        Util.dbString2date(data[0][DatabaseCreator.transactionDate]);
    return DateTime(date[0], date[1], date[2]);
  }

  static Future<int> getNearestYear(int referenceYear) async {
    final d = Util.date2DBString(DateTime(referenceYear, 1, 1));
    final sql =
        ''' SELECT ${DatabaseCreator.transactionDate} FROM ${DatabaseCreator.transactionTable}
    WHERE ${DatabaseCreator.transactionDate} <= ?
    ORDER BY ${DatabaseCreator.transactionDate} DESC LIMIT 1
    ''';
    List<dynamic> params = [d];
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
