import 'package:money_book/model/transaction.dart';
import 'package:money_book/localDB/service/transaction.dart';

class TransactionAPI {
  static Future<void> add(Transaction t) async {
    await TransactionService.addTransaction(t);
  }
  static Future<List<Transaction>> getAll() async {
    List<Transaction> transactions =  await TransactionService.getAll();
    return transactions;
  }
}