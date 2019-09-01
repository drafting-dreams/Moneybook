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
        'commuting',
        'shopping',
        'entertainment',
      ];
      const List<String> icons = [
        'IconData(U+0E57A)',
        'IconData(U+0E88A)',
        'IconData(U+0E195)',
        'IconData(U+0E54C)',
        'IconData(U+0E338)'
      ];
      const List<String> colors = [
        'MaterialAccentColor(primary value: Color(0xffff5252))',
        'MaterialAccentColor(primary value: Color(0xff536dfe))',
        'MaterialAccentColor(primary value: Color(0xffffab40))',
        'MaterialAccentColor(primary value: Color(0xff7c4dff))',
        'MaterialColor(primary value: Color(0xffffc107))'
      ];
      for (int i=0; i<types.length; i++) {
        ExpenseTypeService.createType(types[i], icons[i], colors[i]);
      }
    }
  }

  static Future<void> createType(String name, String icon, String color) async {
    await ExpenseTypeService.createType(name, icon, color);
  }

  static Future<void> modifyType(String oldName, String newName) async {
    await ExpenseTypeService.updateType(oldName, newName);
  }

  static Future<void> deleteType(String name) async {
    await ExpenseTypeService.deleteType(name);
  }
}
