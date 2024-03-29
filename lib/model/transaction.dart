import 'package:money_book/utils/random.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/localDB/database_creator.dart';

class Transaction {
  static const ID_PREFIX_LENGTH = 6;
  String id; // timestamp
  String name = '';
  double value;
  String accountId;
  DateTime date;
  String type;

  Transaction(double v, DateTime dt, String accountId,
      {String type, String name}) {
    this.id = RandomGenerator.str(ID_PREFIX_LENGTH) +
        new DateTime.now().millisecondsSinceEpoch.toString();
    this.accountId = accountId;
    if (name != null) {
      this.name = name;
    }
    this.value = v;
    this.date = dt;
    if (v < 0) {
      this.type = type;
    }
  }

  Transaction.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.transactionId];
    this.name = json[DatabaseCreator.transactionName];
    this.value = json[DatabaseCreator.transactionValue];
    this.accountId = json[DatabaseCreator.accountId];
    List<int> date = Util.dbString2date(json[DatabaseCreator.transactionDate]);
    this.date = new DateTime(date[0], date[1], date[2]);
    this.type = json[DatabaseCreator.transactionType];
  }
}
