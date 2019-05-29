abstract class TransactionType {
  // Add one type
  void add();
  // Remove one type
  void remove();
  // Get the type list
  void getTypes();
}

class IncomeType extends TransactionType {
  static IncomeType _incomeType;

  factory IncomeType() {
    if (_incomeType == null) {
      _incomeType = new IncomeType._internal();
    }
    return _incomeType;
  }

  IncomeType._internal() {}

  @override
  void add() {
    // TODO: implement add
  }

  @override
  void getTypes() {
    // TODO: implement getTypes
  }

  @override
  void remove() {
    // TODO: implement remove
  }
}