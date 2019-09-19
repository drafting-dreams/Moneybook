import 'package:money_book/localDB/service/bill.dart';
import 'package:money_book/model/bill.dart';

class BillAPI {
  static Future<void> add(Bill bill) async {
    await BillService.addBill(bill);
  }
}