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
  static const billTable='billTable';
  static const billAutoPay = 'billAutoPay';
  static const billPaid = 'billPaid';
  static const billAmount = 'billAmount';
  static const billType = 'billType';
  static const billDescription = 'billDescription';
  static const billDueDate = 'billDueDate';
  static const billId = 'billId';
  static const themeTable = 'themeTable';
  static const theme = 'theme';
  static const themeUsing = 'themeUsing';

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

  Future<void> createBillTable(Database db) async {
    final todoSql = '''CREATE TABLE $billTable
    (
      $billId Text PRIMARY KEY,
      $billAutoPay Integer,
      $billPaid Integer,
      $billAmount REAL,
      $billDescription TEXT,
      $billType TEXT,
      $billDueDate TEXT,
      $accountId TEXT
    )''';
    await db.execute(todoSql);
  }

  Future<void> createThemeTable(Database db) async {
    final todoSql = '''CREATE TABLE $themeTable
    (
      $theme Text PRIMARY KEY,
      $themeUsing INTEGER
    )''';
    await db.execute(todoSql);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (await Directory(dirname(path)).exists()) {
      await deleteDatabase(path);
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
    await createBillTable(db);
    await createThemeTable(db);
  }
}
