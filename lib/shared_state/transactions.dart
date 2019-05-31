import 'package:flutter/foundation.dart';
import 'package:money_book/model/transaction.dart';

class Transactions extends ChangeNotifier {
  Transactions();

  List<Transaction> transactions = [];

  void add(Transaction t) {
    this.transactions.add(t);
  }

  void addAll(List<Transaction> t) {
    this.transactions.addAll(t);
  }

  Transaction get(int i) {
    return this.transactions[i];
  }
  int get length {
    return this.transactions.length;
  }
}

