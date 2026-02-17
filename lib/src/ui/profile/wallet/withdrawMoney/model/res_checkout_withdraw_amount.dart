import '../../../../../apis/dic_params.dart';

class ResCheckoutWithdrawMoney {
  Data? data;

  ResCheckoutWithdrawMoney({this.data});

  ResCheckoutWithdrawMoney.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }
}

class Data {
  num? withdrawalVatPercentage;
  num? withdrawalCharges;
  num? withdrawalVatAmount;
  num? amount;
  num? netPayable;

  Data(
      {this.withdrawalVatPercentage,
      this.withdrawalCharges,
      this.withdrawalVatAmount,
      this.amount,
      this.netPayable});

  Data.fromJson(Map<String, dynamic> json) {
    withdrawalVatPercentage = json[DicParams.withdrawalVatPercentage];
    withdrawalCharges = json[DicParams.withdrawalCharges];
    withdrawalVatAmount = json[DicParams.withdrawalVatAmount];
    amount = json[DicParams.amount];
    netPayable = json[DicParams.netPayable];
  }
}
