import 'package:money_book/localDB/database_creator.dart';

class ExpenseTypeService {
  static Future<List<String>> list() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.expenseTypeTable}''';
    final data = await db.rawQuery(sql);
    List<String> types = [];

    for (final node in data) {
      final type = node[DatabaseCreator.expenseTypeName];
      types.add(type);
    }
    return types;
  }

  static Future<void> createType(String name, String icon, String color) async {
    final sql = '''INSERT INTO ${DatabaseCreator.expenseTypeTable}
    (
      ${DatabaseCreator.expenseTypeName},
      ${DatabaseCreator.expenseTypeIcon},
      ${DatabaseCreator.expenseTypeColor}
    )
    VALUES(?,?,?)''';
    List<dynamic> params = [name, icon, color];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog(
        'Created an expense type', sql, null, result, params);
  }

  static Future<void> updateType(String oldName, String newName) async {
    final sql = '''UPDATE ${DatabaseCreator.expenseTypeTable}
    SET ${DatabaseCreator.expenseTypeName} = ?
    WHERE ${DatabaseCreator.expenseTypeName} = ?''';

    List<dynamic> params = [newName, oldName];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Update Expense type', sql, null, result, params);
  }

  static Future<void> deleteType(String name) async {
    final sql = '''DELETE FROM ${DatabaseCreator.expenseTypeTable}
    WHERE ${DatabaseCreator.expenseTypeName} = ?''';
    List<dynamic> params = [name];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete expense type', sql, null, null, params);
  }
}
