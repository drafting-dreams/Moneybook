import 'package:money_book/localDB/service/bill.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/model/bill.dart';
import 'package:money_book/model/transaction.dart';

class BillAPI {
  static Future<Bill> getBillById(String id) async {
    final bill = await BillService.getBillById(id);
    return bill;
  }

  static Future<void> add(Bill bill) async {
    await BillService.addBill(bill);
  }

  static Future<void> pay(String billId, Transaction t) async {
    await BillService.pay(billId);
    await TransactionAPI.add(t);
  }

  static Future<void> modify(String id, Bill newBillInfo) async {
    await BillService.updateBill(id, newBillInfo);
  }

  static Future<List<Bill>> getListByDate(
      String accountId, DateTime start, DateTime end) async {
    List<Bill> bills = await BillService.getListByDate(accountId, start, end);
    return bills;
  }

  static Future<List<Bill>> getPreviousUnpaidBills() async {
    List<Bill> bills = await BillService.getPreviousUnpaidBills();
    return bills;
  }

  static Future<List<Bill>> getListAfterDate(
      String accountId, DateTime date) async {
    List<Bill> bills = await BillService.getListAfterDate(accountId, date);
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

  static Future<List<Bill>> loadPrevious(
      String accountId, DateTime referenceDate) async {
    DateTime nearestDate;
    try {
      nearestDate =
          await BillService.getPreviousNearestDate(accountId, referenceDate);
    } on NoNearestDateException {
      return List<Bill>();
    }
    final re = await getOneMonthList(accountId, nearestDate);
    return re;
  }

  static Future<int> getLastBillYear(String accountId) async {
    final lastYear = await BillService.getLastBillYear(accountId);
    return lastYear;
  }

  static Future<void> deleteById(String id) async {
    await BillService.deleteBill(id);
  }

  static Future<void> deleteByType(String type) async {
    await BillService.deleteBillsByType(type);
  }
}
