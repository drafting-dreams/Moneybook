import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

class DatabaseCreator {
  static const dbName = 'MoneybookDB';
  static const accountTable = 'accountTable';
  static const accountId = 'accountId';
  static const accountName = 'accountName';
  static const accountBalance = 'accountBalance';
  static const accountUsing = 'accountUsing';
  static const transactionTable = 'TransactionTable';
  static const transactionId = 'id';
  static const transactionName = 'name';
  static const transactionDate = 'date';
  static const transactionValue = 'value';
  static const transactionType = 'type';
  static const expenseTypeTable = 'expenseTypeTable';
  static const expenseTypeName = 'expenseTypeName';
  static const expenseTypeIcon = 'expenseTypeIcon';
  static const expenseTypeColor = 'expenseTypeColor';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult,
      List<dynamic> params]) {
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

  Future<void> createExpenseTypeTable(Database db) async {
    final todoSql = '''CREATE TABLE $expenseTypeTable
    (
      $expenseTypeName TEXT PRIMARY KEY,
      $expenseTypeIcon TEXT,
      $expenseTypeColor TEXT
    )''';
    await db.execute(todoSql);
  }

  Future<void> createAccountTable(Database db) async {
    final todoSql = '''CREATE TABLE $accountTable
    (
      $accountId TEXT PRIMARY KEY,
      $accountName TEXT,
      $accountBalance REAL,
      $accountUsing INTEGER
    )''';
    await db.execute(todoSql);
  }

  Future<void> createTransactionTable(Database db) async {
    final todoSql = '''CREATE TABLE $transactionTable
    (
      ${DatabaseCreator.transactionId} TEXT PRIMARY KEY,
      ${DatabaseCreator.transactionName} TEXT,
      ${DatabaseCreator.transactionValue} REAL,
      ${DatabaseCreator.transactionDate} TEXT,
      ${DatabaseCreator.transactionType} TEXT,
      $accountId Text,
          FOREIGN KEY($accountId) REFERENCES $accountTable($accountId)
    );
    CREATE INDEX date_index ON $transactionTable (${DatabaseCreator.transactionDate});
    ''';
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
    await createAccountTable(db);
    await createTransactionTable(db);
    await createExpenseTypeTable(db);
  }
}
