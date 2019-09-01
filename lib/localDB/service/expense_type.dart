import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/model/expense_type.dart';

class ExpenseTypeService {
  static Future<List<ExpenseType>> list() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.expenseTypeTable}''';
    final data = await db.rawQuery(sql);
    List<ExpenseType> types = [];

    for (final node in data) {
      types.add(ExpenseType.fromJson(node));
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

  static Future<void> updateType(
      String oldName, String newName, String newIcon, String newColor) async {
    final sql = '''UPDATE ${DatabaseCreator.expenseTypeTable}
    SET ${DatabaseCreator.expenseTypeName} = ?,
    ${DatabaseCreator.expenseTypeIcon} = ?,
    ${DatabaseCreator.expenseTypeColor} = ?
    WHERE ${DatabaseCreator.expenseTypeName} = ?''';

    List<dynamic> params = [newName, newIcon, newColor, oldName];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog(
        'Update Expense type', sql, null, result, params);
  }

  static Future<void> deleteType(String name) async {
    final sql = '''DELETE FROM ${DatabaseCreator.expenseTypeTable}
    WHERE ${DatabaseCreator.expenseTypeName} = ?''';
    List<dynamic> params = [name];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete expense type', sql, null, null, params);
  }
}
