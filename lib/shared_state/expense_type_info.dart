import 'package:flutter/foundation.dart';
import 'package:money_book/model/expense_type.dart';

class ExpenseTypeInfo extends ChangeNotifier {
  List<ExpenseType> types = [];

  void add(ExpenseType type) {
    types.add(type);
    notifyListeners();
  }

  void addAll(List<ExpenseType> types) {
    this.types.addAll(types);
    notifyListeners();
  }

  void clear() {
    types.clear();
    notifyListeners();
  }

  void delete(String name) {
    types.removeAt(types.indexWhere((t) => t.name == name));
    notifyListeners();
  }

  void update(String oldName, newExpenseType) {
    types[types.indexWhere((t) => t.name == oldName)] = newExpenseType;
    notifyListeners();
  }
}
