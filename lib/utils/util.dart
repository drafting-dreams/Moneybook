class Util {
  static bool isNumeric(String str) {
    try {
      double.parse(str);
    } on FormatException {
      return false;
    }
    return true;
  }

  static bool isInt(String str) {
    try {
      int.parse(str);
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

  static bool isTheSameDay(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  static Map getMonthName(int month) {
    switch (month) {
      case 1:
        return {'en': 'Jan', 'zh': '一月'};
      case 2:
        return {'en': 'Feb', 'zh': '二月'};
      case 3:
        return {'en': 'Mar', 'zh': '三月'};
      case 4:
        return {'en': 'Apr', 'zh': '四月'};
      case 5:
        return {'en': 'May', 'zh': '五月'};
      case 6:
        return {'en': 'Jun', 'zh': '六月'};
      case 7:
        return {'en': 'Jul', 'zh': '七月'};
      case 8:
        return {'en': 'Aug', 'zh': '八月'};
      case 9:
        return {'en': 'Sep', 'zh': '九月'};
      case 10:
        return {'en': 'Oct', 'zh': '十月'};
      case 11:
        return {'en': 'Nov', 'zh': '十一月'};
      case 12:
        return {'en': 'Dec', 'zh': '十二月'};
    }
    throw Exception('Month out of range');
  }
}
