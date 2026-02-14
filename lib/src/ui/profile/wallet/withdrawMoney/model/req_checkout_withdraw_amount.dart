import '../../../../../apis/dic_params.dart';

class ReqCheckoutWithdrawMoney {
  num? amount;

  ReqCheckoutWithdrawMoney({this.amount});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.amount] = amount;
    return data;
  }
}
