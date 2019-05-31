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

  static Future<List<Transaction>> getAll() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.transactionTable}
    ''';
    final data = await db.rawQuery(sql);
    List<Transaction> transactions = List();

    for (final node in data) {
      final transaction = Transaction.fromJson(node);
      transactions.add(transaction);
    }
    return transactions;
  }
}
