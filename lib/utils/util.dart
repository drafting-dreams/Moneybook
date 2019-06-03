import 'package:money_book/model/transaction.dart';

class Util {
  static bool isNumeric(String str) {
    try {
      double.parse(str);
    } on FormatException {
      return false;
    }
    return true;
  }

  static String date2DBString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static List<int> dbString2date(String str) {
    return str.split('-').map((num) => int.parse(num)).toList();
  }

  static String expenseType2String(ExpenseType type) {
    return type.toString().substring(12);
  }
}
