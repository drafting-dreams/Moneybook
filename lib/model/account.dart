import 'package:money_book/utils/random.dart';
import 'package:money_book/localDB/database_creator.dart';

class Account {
  static const ID_PREFIX_LENGTH = 6;
  String id;
  String name = '';
  double balance;

  Account(String name, [double balance = 0]) {
    this.id = RandomGenerator.str(ID_PREFIX_LENGTH) +
        new DateTime.now().millisecondsSinceEpoch.toString() +
        name;
    this.name = name;
    this.balance = balance;
  }

  Account.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.accountId];
    this.name = json[DatabaseCreator.accountName];
    this.balance = json[DatabaseCreator.accountBalance];
  }
}
