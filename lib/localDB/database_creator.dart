import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

class DatabaseCreator {
  static const dbName = 'MoneybookDB';
  static const transactionTable = 'TransactionTable';
  static const transactionId = 'id';
  static const transactionName = 'name';
  static const transactionDate = 'date';
  static const transactionValue = 'value';
  static const transactionType = 'type';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult, List<dynamic> params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createTransactionTable(Database db) async {
    final todoSql = '''CREATE TABLE $transactionTable
    (
      ${DatabaseCreator.transactionId} STRING PRIMARY KEY,
      ${DatabaseCreator.transactionName} STRING,
      ${DatabaseCreator.transactionValue} REAL,
      ${DatabaseCreator.transactionDate} TEXT,
      ${DatabaseCreator.transactionType} STRING
    )''';
    await db.execute(todoSql);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (await Directory(dirname(path)).exists()) {
//      await deleteDatabase(path);
    } else {
      Directory(path).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath(dbName);
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTransactionTable(db);
  }
}
