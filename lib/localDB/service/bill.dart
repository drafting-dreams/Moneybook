import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/model/bill.dart';
import 'package:money_book/utils/util.dart';

class BillService {
  static Future<void> addBill(Bill bill) async {
    final sql = '''INSERT INTO ${DatabaseCreator.billTable}
    (
      ${DatabaseCreator.billId},
      ${DatabaseCreator.accountId},
      ${DatabaseCreator.billDueDate},
      ${DatabaseCreator.billPaid},
      ${DatabaseCreator.billAutoPay},
      ${DatabaseCreator.billType},
      ${DatabaseCreator.billAmount},
      ${DatabaseCreator.billDescription}
    )
    VALUES(?,?,?,?,?,?,?,?)''';
    List<dynamic> params = [
      bill.id,
      bill.accountId,
      Util.date2DBString(bill.dueDate),
      bill.paid ? 1 : 0,
      bill.autoPay ? 1 : 0,
      bill.type,
      bill.value,
      bill.name
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add bill', sql, null, result, params);
  }

  static Future<List<Bill>> getListByDate(
      String accountId, DateTime start, DateTime end) async {
    final s = Util.date2DBString(start);
    final e = Util.date2DBString(end);
    final sql = '''SELECT * FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.billDueDate} >= ?
    AND ${DatabaseCreator.billDueDate} <= ?
    ORDER BY ${DatabaseCreator.billDueDate} ASC''';
    List<dynamic> params = [accountId, s, e];
    final data = await db.rawQuery(sql, params);
    List<Bill> bills = List();

    for (final node in data) {
      final bill = Bill.fromJson(node);
      bills.add(bill);
    }
    return bills;
  }

  static Future<List<Bill>> getListAfterDate(String accountId, DateTime date) async {
    final d = Util.date2DBString(date);
    final sql = '''SELECT * FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.billDueDate} >= ?
    ORDER BY ${DatabaseCreator.billDueDate} ASC''';
    List<dynamic> params = [accountId, d];
    final data = await db.rawQuery(sql, params);
    List<Bill> bills = List();
    for (final node in data) {
      final bill = Bill.fromJson(node);
      bills.add(bill);
    }
    return bills;
  }

  static Future<DateTime> getNextNearestDate(
      String accountId, DateTime referenceDate) async {
    final nextMonthFirstDay = referenceDate.month == 12
        ? DateTime(referenceDate.year + 1, 1, 1)
        : DateTime(referenceDate.year, referenceDate.month + 1, 1);
    final d = Util.date2DBString(nextMonthFirstDay);
    final sql =
        '''SELECT ${DatabaseCreator.billDueDate} FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.billDueDate} >= ?
    ORDER BY ${DatabaseCreator.billDueDate} ASC LIMIT 1''';
    List<dynamic> params = [accountId, d];
    final data = await db.rawQuery(sql, params);
    if (data.length < 1) {
      throw NoNearestDateException();
    }
    List<int> date = Util.dbString2date(data[0][DatabaseCreator.billDueDate]);
    return DateTime(date[0], date[1], date[2]);
  }

  static Future<void> deleteBill(String id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.billId} = ?''';
    List<dynamic> params = [id];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete bill by id', sql, null, null, params);
  }

  static Future<void> deleteBillsByType(String type) async {
    final sql = '''DELETE FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.billType} = ?''';
    List<dynamic> params = [type];
    await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete bill by type', sql, null, null, params);
  }
}

class NoNearestDateException implements Exception {
  final String msg;

  const NoNearestDateException([this.msg]);

  String toString() => msg ?? 'No nearest date found';
}
