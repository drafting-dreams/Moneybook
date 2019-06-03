import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/service/transaction.dart';

class TransactionAPI {
  static Future<void> add(Transaction t) async {
    await TransactionService.addTransaction(t);
  }

  static Future<List<Transaction>> getAll() async {
    List<Transaction> transactions = await TransactionService.getAll();
    return transactions;
  }

  static Future<List<Transaction>> _getOneMonthList(
      DateTime referenceDate) async {
    final start = new DateTime(referenceDate.year, referenceDate.month, 1);
    // This gives you the previous month's last day
    final end = referenceDate.month == 12
        ? DateTime(referenceDate.year + 1, 1, 0)
        : DateTime(referenceDate.year, referenceDate.month + 1, 0);
    List<Transaction> transactions =
        await TransactionService.getListByDate(start, end);
    return transactions;
  }

  static Future<List<Transaction>> loadPrevious(DateTime referenceDate) async {
    DateTime nearestDate;
    try {
      nearestDate = await TransactionService.getNearestDate(
        referenceDate);
    } on NoNearestDateException {
      return List<Transaction>();
    }
    final re = await _getOneMonthList(nearestDate);
    return re;
  }
}
