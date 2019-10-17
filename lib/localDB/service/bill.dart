import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/model/bill.dart';
import 'package:money_book/utils/util.dart';

class BillService {
  static Future<Bill> getBillById(String id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.billId} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);
    List<Bill> bills = List();

    for (final node in data) {
      final bill = Bill.fromJson(node);
      bills.add(bill);
    }

    return bills[0];
  }

  static Future<void> pay(String id) async {
    final sql = '''UPDATE ${DatabaseCreator.billTable}
    SET ${DatabaseCreator.billPaid} = ?
    WHERE ${DatabaseCreator.billId} = ?''';
    List<dynamic> params = [1, id];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Pay bill', sql, null, result, params);
  }

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

  static Future<void> updateBill(String id, Bill bill) async {
    final sql = '''UPDATE ${DatabaseCreator.billTable}
    SET ${DatabaseCreator.billAutoPay} = ?,
    ${DatabaseCreator.billAmount} = ?,
    ${DatabaseCreator.billDescription} = ?,
    ${DatabaseCreator.billType} = ?,
    ${DatabaseCreator.billDueDate} = ?
    WHERE ${DatabaseCreator.billId} = ?''';

    List<dynamic> params = [
      bill.autoPay,
      bill.value,
      bill.name,
      bill.type,
      Util.date2DBString(bill.dueDate),
      id
    ];
    final result = await db.rawUpdate(sql, params);
    DatabaseCreator.databaseLog('Update bill', sql, null, result, params);
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

  static Future<List<Bill>> getPreviousUnpaidBills() async {
    DateTime today = DateTime.now();
    final t = Util.date2DBString(today);
    final sql = '''SELECT * FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.billAutoPay} = 1
    AND ${DatabaseCreator.billPaid} = 0
    AND ${DatabaseCreator.billDueDate} <= ?''';

    List <dynamic> params = [t];
    final data = await db.rawQuery(sql, params);
    List<Bill> bills = List();

    for (final node in data) {
      final bill = Bill.fromJson(node);
      bills.add(bill);
    }
    return bills;
  }

  static Future<List<Bill>> getListAfterDate(
      String accountId, DateTime date) async {
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

  static Future<DateTime> getPreviousNearestDate(
      String accountId, DateTime referenceDate) async {
    final previousMonthLastDay =
        DateTime(referenceDate.year, referenceDate.month, 0);
    final d = Util.date2DBString(previousMonthLastDay);
    final sql =
        '''SELECT ${DatabaseCreator.billDueDate} FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.accountId} = ?
    AND ${DatabaseCreator.billDueDate} <= ?
    ORDER BY ${DatabaseCreator.billDueDate} DESC LIMIT 1''';
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

  static Future<int> getLastBillYear(String accountId) async {
    final sql = '''SELECT ${DatabaseCreator.billDueDate} FROM ${DatabaseCreator.billTable}
    WHERE ${DatabaseCreator.accountId} = ?
    ORDER BY ${DatabaseCreator.billDueDate} DESC LIMIT 1''';
    List<dynamic> params = [accountId];
    final result = await db.rawQuery(sql, params);
    if (result.length < 1) {
      return 0;
    }
    return int.parse(result[0][DatabaseCreator.billDueDate].substring(0, 4));
  }
}

class NoNearestDateException implements Exception {
  final String msg;

  const NoNearestDateException([this.msg]);

  String toString() => msg ?? 'No nearest date found';
}
