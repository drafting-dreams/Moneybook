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
    return '${dt.year}-${dt.month}-${dt.day}';
  }
  static List<int> dbString2date(String str) {
    return str.split('-').map((num) => int.parse(num)).toList();
  }
}