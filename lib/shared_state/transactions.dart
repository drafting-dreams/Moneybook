import 'package:flutter/foundation.dart';
import 'package:money_book/model/transaction.dart';

enum TransactionClass { all, income, expense }

class Transactions extends ChangeNotifier {
  List<Transaction> transactions = [];
  TransactionClass tc = TransactionClass.all;

  List<Transaction> get filtered {
    switch (tc) {
      case TransactionClass.expense:
        return transactions.where((Transaction t) => t.value < 0).toList();
      case TransactionClass.income:
        return transactions.where((Transaction t) => t.value > 0).toList();
      default:
        return transactions;
    }
  }

  void clear() {
    this.transactions = [];
    notifyListeners();
  }

  void setClass(TransactionClass c) {
    tc = c;
    notifyListeners();
  }

  void removeById(String id) {
    transactions
        .removeAt(transactions.indexWhere((Transaction t) => t.id == id));
    notifyListeners();
  }

  void removeByType(String type) {
    transactions = transactions.where((t) => t.type != type).toList();
    notifyListeners();
  }

  void sort() {
    transactions.sort((a, b) => a.date.compareTo(b.date));
  }

  void add(Transaction t) {
    if (transactions.length == 0) {
      transactions.add(t);
      return;
    }
    Transaction firstTransaction = transactions[0];
    if (t.date.compareTo(firstTransaction.date) < 0 &&
        (t.date.month != firstTransaction.date.month ||
            t.date.year != firstTransaction.date.year)) {
    } else {
      if (this.transactions.any((item) =>
          t.date.year == item.date.year && t.date.month == item.date.month)) {
        final lastSameMonthIdx = this.transactions.lastIndexWhere((item) =>
            item.date.year == t.date.year && item.date.month == t.date.month);
        if (t.date.compareTo(this.transactions[lastSameMonthIdx].date) < 0) {
          if (lastSameMonthIdx + 1 < this.transactions.length) {
            this.transactions.insert(lastSameMonthIdx + 1, t);
            notifyListeners();
          } else {
            this.transactions.add(t);
            notifyListeners();
          }
        } else {
          final idx = this.transactions.indexWhere((item) =>
              t.date.compareTo(item.date) >= 0 &&
              t.date.year == item.date.year &&
              t.date.month == item.date.month);
          this.transactions.insert(idx, t);
          notifyListeners();
        }
      } else {
        // Find the first transaction's date which is after the added one, and insert it here
        final idx = this
            .transactions
            .indexWhere((element) => t.date.compareTo(element.date) < 0);
        if (idx >= 0) {
          this.transactions.insert(idx, t);
          notifyListeners();
        } else if (idx < 0) {
          this.transactions.add(t);
          notifyListeners();
        }
      }
    }
  }

  void update(String id, Transaction info) {
    final idx = transactions.indexWhere((element) => id == element.id);
    if (info.date.compareTo(transactions[0].date) < 0 &&
        (info.date.month != transactions[0].date.month ||
            info.date.year != transactions[0].date.year)) {
      transactions.removeAt(idx);
    } else {
      Transaction old = transactions[idx];
      old.value = info.value;
      old.name = info.name;
      old.date = info.date;
      old.type = info.type;
      transactions.removeAt(idx);
      this.add(old);
    }
  }

  void addAll(List<Transaction> t) {
    this.transactions.addAll(t);
    notifyListeners();
  }

  void addBefore(List<Transaction> t) {
    this.transactions = t..addAll(this.transactions);
    notifyListeners();
  }

  Transaction get(int i) {
    if (this.filtered.length < 1) return null;
    return this.filtered[i];
  }

  int get length {
    return this.filtered.length;
  }

  DateTime get previousLoadingReference {
    if (this.transactions.length < 1) {
      return DateTime.now();
    }
    return this.transactions[0].date;
  }

  double getTotalOfMonth(DateTime dt) {
    return this
        .filtered
        .where((transaction) =>
            dt.year == transaction.date.year &&
            dt.month == transaction.date.month)
        .toList()
        .fold(0.0, (current, next) => current + next.value);
  }
}

class NoTransactionAvailableException implements Exception {
  final msg;

  const NoTransactionAvailableException([this.msg]);

  String toString() => msg ?? 'No transaction available';
}
