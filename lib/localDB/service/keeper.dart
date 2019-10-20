import 'package:money_book/localDB/database_creator.dart';

class KeeperService {
  static Future<List<int>> getAll() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.idKeeper}''';
    final data = await db.rawQuery(sql);
    List<int> keepers = [];

    for (final node in data) {
      keepers.add(node[DatabaseCreator.notificationId]);
    }
    print(keepers.length.toString() + 'keeper length');

    return keepers;
  }

  static Future<void> createKeeper(int initialId) async {
    final sql = '''INSERT INTO ${DatabaseCreator.idKeeper}
    (
      ${DatabaseCreator.keeperId},
      ${DatabaseCreator.notificationId}
    )
    VALUES(?,?)''';
    List<dynamic> params = [0, initialId];
    final result = await db.rawInsert(sql, params);
    print('initialized keepeer');
    DatabaseCreator.databaseLog(
        'Created a new keeper', sql, null, result, params);
  }

  static Future<void> update(int newId) async {
    final sql = '''UPDATE ${DatabaseCreator.idKeeper}
    SET ${DatabaseCreator.notificationId} = ?
    WHERE ${DatabaseCreator.keeperId} = 0''';
    List<dynamic> params = [newId];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Update account', sql, null, result, params);
  }

}
