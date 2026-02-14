import 'package:flutter/material.dart';

import '../model/res_data_plan_list.dart';

class UtilityServiceProvider extends ChangeNotifier {
  UtilityServiceProvider();

  DataPlanItem _selectedDataPlan = DataPlanItem();
  String _customerName = "";
  String _amount = "";

  DataPlanItem get selectedDataPlan {
    return _selectedDataPlan;
  }

  String get customerName {
    return _customerName;
  }

  String get amount {
    String amount;
    amount = _selectedDataPlan.variationAmount ?? '';
    return amount;
  }

  void setSelectedDataPlan(DataPlanItem selectedPlan) {
    _selectedDataPlan = selectedPlan;
    notifyListeners();
  }

  void setCustomerName(String customerName) {
    _customerName = customerName;
    notifyListeners();
  }

  void setAmount(String amount) {
    _amount = amount;
    notifyListeners();
  }

  void clearData() {
    _selectedDataPlan = DataPlanItem();
    _customerName = "";
    _amount = "";
    notifyListeners();
  }
}
