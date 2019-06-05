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
      nearestDate = await TransactionService.getNearestDate(referenceDate);
    } on NoNearestDateException {
      return List<Transaction>();
    }
    final re = await _getOneMonthList(nearestDate);
    return re;
  }

  static Future<List<Map<String, dynamic>>> loadPreviousYear(int year) async {
    int nearestYear;
    try {
      nearestYear = await TransactionService.getNearestYear(year);
    } on NoNearestDateException {
      return List<Map<String, dynamic>>();
    }
    final re = await getListByMonth(nearestYear);
    return re;
  }

  static Future<List<Map<String, dynamic>>> getListByYear() async {
    var futures = <Future<List<Transaction>>>[];

    for (int year = 2019; year <= DateTime.now().year; year++) {
      futures.add(TransactionService.getListByDate(
          DateTime(year, 1, 1), DateTime(year, 12, 31)));
    }

    final List<List<Transaction>> transactionsGroupByYear =
        await Future.wait(futures);
    return transactionsGroupByYear.where((list) => list.length > 0).map((list) {
      return {
        'year': list[0].date.year,
        'amount': list.fold(
            0.0, (current, transaction) => current + transaction.value)
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getListByMonth(year) async {
    var futures = <Future<List<Transaction>>>[];

    for (int month = 1; month <= 12; month++) {
      DateTime start = DateTime(year, month, 1);
      DateTime end =
          month == 12 ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0);
      futures.add(TransactionService.getListByDate(start, end));
    }

    final List<List<Transaction>> transactionsGroupByMonth =
        await Future.wait(futures);
    return transactionsGroupByMonth
        .where((list) => list.length > 0)
        .map((list) {
      return {
        'year': list[0].date.year,
        'month': list[0].date.month,
        'amount': list.fold(
            0.0, (current, transaction) => current + transaction.value)
      };
    }).toList();
  }
}
