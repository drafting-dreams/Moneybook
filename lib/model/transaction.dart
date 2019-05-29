import 'package:money_book/utils/random.dart';

class Transaction {
  static final ID_PREFIX_LENGTH = 6;
  String id; // timestamp
  String name = '';
  double value;

  Transaction(double v, [String name]) {
    this.id = RandomGenerator.str(ID_PREFIX_LENGTH) +
        new DateTime.now().millisecondsSinceEpoch.toString();
    if (name != null) {
      this.name = name;
    }
    this.value = v;
  }
}
