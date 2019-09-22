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
}
