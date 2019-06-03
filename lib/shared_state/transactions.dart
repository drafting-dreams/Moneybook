import 'package:flutter/foundation.dart';
import 'package:money_book/model/transaction.dart';

class Transactions extends ChangeNotifier {

  List<Transaction> transactions = [];

  Transactions();

  void add(Transaction t) {
    this.transactions.add(t);
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
    return this.transactions[0].date;
  }
}
