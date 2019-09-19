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
      bill.paid,
      bill.autoPay,
      bill.type,
      bill.value,
      bill.name
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add bill', sql, null, result, params);
  }
}