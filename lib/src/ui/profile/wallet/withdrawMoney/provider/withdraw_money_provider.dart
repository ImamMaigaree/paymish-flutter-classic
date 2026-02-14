import 'package:flutter/material.dart';

import '../model/res_checkout_withdraw_amount.dart';

class WithdrawMoneyProvider extends ChangeNotifier {
  ResCheckoutWithdrawMoney _amountData = ResCheckoutWithdrawMoney();

  ResCheckoutWithdrawMoney get amountData {
    return _amountData;
  }

  void setAmountData(ResCheckoutWithdrawMoney data) {
    _amountData = data;
    notifyListeners();
  }

  void clearAllData() {
    _amountData = ResCheckoutWithdrawMoney();
    notifyListeners();
  }
}
