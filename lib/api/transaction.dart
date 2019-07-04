import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/service/transaction.dart';
import 'package:money_book/localDB/service/account.dart';
import 'package:money_book/model/account.dart';

class TransactionAPI {
  static Future<void> add(Transaction t) async {
    await TransactionService.addTransaction(t);
    Account account = await AccountService.getAccountById(t.accountId);
    await AccountService.updateAccount(
        account.id, account.name, account.balance + t.value);
  }

  static Future<List<Transaction>> getAll(String accountId) async {
    List<Transaction> transactions = await TransactionService.getAll(accountId);
    return transactions;
  }

  static Future<List<Transaction>> _getOneMonthList(
      String accountId, DateTime referenceDate) async {
    final start = new DateTime(referenceDate.year, referenceDate.month, 1);
    // This gives you the previous month's last day
    final end = referenceDate.month == 12
        ? DateTime(referenceDate.year + 1, 1, 0)
        : DateTime(referenceDate.year, referenceDate.month + 1, 0);
    List<Transaction> transactions =
        await TransactionService.getListByDate(accountId, start, end);
    return transactions;
  }

  static Future<List<Transaction>> loadPrevious(
      String accountId, DateTime referenceDate) async {
    DateTime nearestDate;
    try {
      nearestDate =
          await TransactionService.getNearestDate(accountId, referenceDate);
    } on NoNearestDateException {
      return List<Transaction>();
    }
    final re = await _getOneMonthList(accountId, nearestDate);
    return re;
  }

  static Future<List<Map<String, dynamic>>> loadPreviousYear(
      String accountId, int year) async {
    int nearestYear;
    try {
      nearestYear = await TransactionService.getNearestYear(accountId, year);
    } on NoNearestDateException {
      return List<Map<String, dynamic>>();
    }
    final re = await getListByMonth(accountId, nearestYear);
    return re;
  }

  static Future<List<Map<String, dynamic>>> getListByYear(
      String accountId) async {
    var futures = <Future<List<Transaction>>>[];

    for (int year = 2019; year <= DateTime.now().year; year++) {
      futures.add(TransactionService.getListByDate(
          accountId, DateTime(year, 1, 1), DateTime(year, 12, 31)));
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

  static Future<List<Map<String, dynamic>>> getListByMonth(
      String accountId, int year) async {
    var futures = <Future<List<Transaction>>>[];

    for (int month = 1; month <= 12; month++) {
      DateTime start = DateTime(year, month, 1);
      DateTime end =
          month == 12 ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0);
      futures.add(TransactionService.getListByDate(accountId, start, end));
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
