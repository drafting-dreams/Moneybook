import 'package:money_book/utils/random.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/localDB/database_creator.dart';

enum ExpenseType { food, commute, cloth, housing, communication, electronic, others }

class Transaction {
  static const ID_PREFIX_LENGTH = 6;
  String id; // timestamp
  String name = '';
  double value;
  DateTime date;
  ExpenseType type;

  Transaction(double v, DateTime dt, {ExpenseType type, String name}) {
    this.id = RandomGenerator.str(ID_PREFIX_LENGTH) +
        new DateTime.now().millisecondsSinceEpoch.toString();
    this.date = new DateTime.now();
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
    List<int> date = Util.dbString2date(json[DatabaseCreator.transactionDate]);
    this.date = new DateTime(date[0], date[1], date[2]);
    if (json[DatabaseCreator.transactionType] != null) {
      for (ExpenseType t in ExpenseType.values) {
        if (t.toString() == json[DatabaseCreator.transactionType]) {
          this.type = t;
        }
      }
    }
  }
}
