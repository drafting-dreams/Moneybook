import 'package:money_book/localDB/service/bill.dart';
import 'package:money_book/model/bill.dart';

class BillAPI {
  static Future<void> add(Bill bill) async {
    await BillService.addBill(bill);
  }

  static Future<List<Bill>> getListByDate(
      String accountId, DateTime start, DateTime end) async {
    List<Bill> bills = await BillService.getListByDate(accountId, start, end);
    return bills;
  }

  static Future<List<Bill>> getOneMonthList(
      String accountId, DateTime referenceDate) async {
    final start = new DateTime(referenceDate.year, referenceDate.month, 1);
    final end = referenceDate.month == 12
        ? DateTime(referenceDate.year + 1, 1, 0)
        : DateTime(referenceDate.year, referenceDate.month + 1, 0);
    List<Bill> bills = await BillService.getListByDate(accountId, start, end);
    return bills;
  }

  static Future<void> deleteById(String id) async {
    await BillService.deleteBill(id);
  }

  static Future<void> deleteByType(String type) async {
    await BillService.deleteBillsByType(type);
  }
}
