import 'package:flutter/material.dart';

class BankSelectionProvider extends ChangeNotifier {
  // Selected Index of Current Payment Method
  int _selectedIndex = 0;

  // Count of All The Banks
  int _bankListCount = 0;

  int getIndex() => _selectedIndex;

  int getBankListCount() => _bankListCount;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setBankListCount(int count) {
    _bankListCount = count;
    notifyListeners();
  }
}
