import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/service/transaction.dart';
import 'package:money_book/localDB/service/account.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/shared_state/transactions.dart';

class TransactionAPI {
  static Future<Transaction> getTransactionById(String id) async {
    final transaction = await TransactionService.getTransactionById(id);
    return transaction;
  }

  static Future<void> add(Transaction t) async {
    await TransactionService.addTransaction(t);
    Account account = await AccountService.getAccountById(t.accountId);
    await AccountService.updateAccount(
        account.id, account.name, account.balance + t.value);
  }

  static Future<void> delete(String id,
      [String accountId, double transactionValue]) async {
    await TransactionService.deleteTransactionById(id);
    if (accountId != null) {
      Account account = await AccountService.getAccountById(accountId);
      await AccountService.updateAccount(
          account.id, account.name, account.balance - transactionValue);
    }
  }

  static Future<void> deleteByType(String type) async {
    await TransactionService.deleteTransactionsByType(type);
  }

  static Future<void> modify(String id, Transaction newTransactionInfo) async {
    await TransactionService.updateTransaction(id, newTransactionInfo);
  }

  static Future<List<Transaction>> getAll(String accountId) async {
    List<Transaction> transactions = await TransactionService.getAll(accountId);
    return transactions;
  }

  static Future<List<Transaction>> getListByDate(
      String accountId, DateTime start, DateTime end) async {
    List<Transaction> transactions =
        await TransactionService.getListByDate(accountId, start, end);
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
      String accountId, int year, TransactionClass tc) async {
    int nearestYear;
    try {
      nearestYear = await TransactionService.getNearestYear(accountId, year);
    } on NoNearestDateException {
      return List<Map<String, dynamic>>();
    }
    final re = await getListByMonth(accountId, nearestYear, tc);
    return re;
  }

  static Future<List<Map<String, dynamic>>> getListByYear(
      String accountId, TransactionClass tc) async {
    var futures = <Future<double>>[];
    for (int year = 2019; year <= DateTime.now().year; year++) {
      futures.add(TransactionService.getSumByDate(
          accountId, DateTime(year, 1, 1), DateTime(year, 12, 31), tc));
    }
    List<double> sums = await Future.wait(futures);
    List<Map<String, dynamic>> re = [];
    for (var i = 0; i < sums.length; i++) {
      re.add({'year': 2019 + i, 'amount': sums[i]});
    }
    return re.where((item) => item['amount'] != null).toList();
  }

  static Future<List<Map<String, dynamic>>> getListByMonth(
      String accountId, int year, TransactionClass tc) async {
    var futures = <Future<double>>[];

    for (int month = 1; month <= 12; month++) {
      DateTime start = DateTime(year, month, 1);
      DateTime end =
          month == 12 ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0);
      futures.add(TransactionService.getSumByDate(accountId, start, end, tc));
    }

    final List<double> sums = await Future.wait(futures);
    List<Map<String, dynamic>> re = [];
    for (var i = 0; i < sums.length; i++) {
      re.add({'year': year, 'month': i + 1, 'amount': sums[i]});
    }
    return re.where((item) => item['amount'] != null).toList();
  }

  static Future<Map<String, double>> getSumByTypeGroup(
      String accountId, int year,
      [int month]) {
    if (month == null) {
      return TransactionService.getSumByDateGroupByType(
          accountId, DateTime(year, 1, 1), DateTime(year, 12, 31));
    }
    DateTime end =
        month == 12 ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0);
    return TransactionService.getSumByDateGroupByType(
        accountId, DateTime(year, month, 1), end);
  }

  static Future<Map<String, double>> getSumByTypeGroupSpecific(
      String accountId, DateTime start, DateTime end) {
    return TransactionService.getSumByDateGroupByType(accountId, start, end);
  }
}
