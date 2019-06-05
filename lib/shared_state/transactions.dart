import 'package:flutter/foundation.dart';
import 'package:money_book/model/transaction.dart';

class Transactions extends ChangeNotifier {
  List<Transaction> transactions = [];

  Transactions();

  void clear() {this.transactions = [];notifyListeners();}

  void add(Transaction t) {
    // Find the first transaction's date which is after the added one, and insert it here
    final idx = this.transactions.indexWhere((element) => t.date.compareTo(element.date) < 0);
    if (idx > 0) {
      this.transactions.insert(idx, t);
      notifyListeners();
    } else if (idx < 0) {
      this.transactions.add(t);
      notifyListeners();
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
    return this.transactions[i];
  }

  int get length {
    return this.transactions.length;
  }

  DateTime get previousLoadingReference {
    if (this.transactions.length < 1) {
      return null;
    }
    return this.transactions[0].date;
  }

  double getTotalOfMonth(DateTime dt) {
    return this
        .transactions
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
