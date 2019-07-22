import 'package:money_book/localDB/service/expense_type.dart';

class ExpenseTypeAPI {
  static Future<List<String>> list() async {
    final List<String> types = await ExpenseTypeService.list();
    return types;
  }

  static Future<void> initializingTypes() async {
    final List<String> list = await ExpenseTypeService.list();
    if (list.length == 0) {
      const List<String> types = [
        'food',
        'housing',
        'entertainment',
        'communication',
        'clothes',
        'electronic',
        'others'
      ];
      for (var type in types) {
        ExpenseTypeService.createType(type);
      }
    }
  }

  static Future<void> createType(String name) async {
    await ExpenseTypeService.createType(name);
  }

  static Future<void> modifyType(String oldName, String newName) async {
    await ExpenseTypeService.updateType(oldName, newName);
  }

  static Future<void> deleteType(String name) async {
    await ExpenseTypeService.deleteType(name);
  }
}
