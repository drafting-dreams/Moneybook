import 'package:money_book/utils/random.dart';
import 'package:money_book/utils/util.dart';
import 'package:money_book/localDB/database_creator.dart';

class Bill {
  static const ID_PREFIX_LENGTH = 6;
  String id;
  String name = '';
  double value;
  String accountId;
  DateTime dueDate;
  String type;
  bool autoPay;
  bool paid;

  Bill(double v, DateTime dt, String accountId, String type, bool autoPay,
      bool paid,
      {String name}) {
    this.id = RandomGenerator.str(ID_PREFIX_LENGTH) +
        new DateTime.now().millisecondsSinceEpoch.toString();
    this.dueDate = dt;
    this.accountId = accountId;
    if (name != null) {
      this.name = name;
    }
    this.type = type;
    this.autoPay = autoPay;
    this.paid = paid;
    this.value = v;
  }

  Bill.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.billId];
    this.name = json[DatabaseCreator.billDescription];
    List<int> date = Util.dbString2date(json[DatabaseCreator.billDueDate]);
    this.dueDate = DateTime(date[0], date[1], date[2]);
    this.accountId = json[DatabaseCreator.accountId];
    this.type = json[DatabaseCreator.billType];
    this.autoPay = json[DatabaseCreator.billAutoPay] == 1 ? true : false;
    this.paid = json[DatabaseCreator.billPaid] == 1 ? true : false;
    this.value = json[DatabaseCreator.billAmount];
  }
}
