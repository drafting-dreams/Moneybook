import 'package:money_book/localDB/database_creator.dart';

class ThemeService {
  static Future<List<String>> list() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.themeTable}''';
    final data = await db.rawQuery(sql);
    List<String> themes = List();
    for (final node in data) {
      themes.add(node[DatabaseCreator.theme]);
    }
    return themes;
  }

  static Future<void> add(String name, int using) async {
    final sql = '''INSERT INTO ${DatabaseCreator.themeTable}
    (
      ${DatabaseCreator.theme},
      ${DatabaseCreator.themeUsing}
    )
    VALUES(?,?)''';
    List<dynamic> params = [name, using];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add theme', sql, null, result, params);
  }

  static Future<void> setTheme(String name) async {
    final sql1 = '''UPDATE ${DatabaseCreator.themeTable}
    SET ${DatabaseCreator.themeUsing} = 0
    WHERE ${DatabaseCreator.themeUsing} != 0''';
    final sql2 = '''UPDATE ${DatabaseCreator.themeTable}
    SET ${DatabaseCreator.themeUsing} = 1
    WHERE ${DatabaseCreator.theme} = ?''';
    await db.rawUpdate(sql1);
    List<dynamic> params = [name];
    final result = await db.rawUpdate(sql2, params);
    DatabaseCreator.databaseLog('Set theme', sql2, null, result, params);
  }

  static Future<String> getUsing() async {
    final sql = '''SELECT ${DatabaseCreator.theme} from ${DatabaseCreator.themeTable}
    WHERE ${DatabaseCreator.themeUsing} = 1''';
    final data = await db.rawQuery(sql);
    List<String> themes = List();
    for (final node in data) {
      themes.add(node[DatabaseCreator.theme]);
    }
    return themes[0];
  }
}
