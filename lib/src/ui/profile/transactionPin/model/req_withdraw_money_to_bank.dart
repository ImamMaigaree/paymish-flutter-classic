import '../../../../apis/dic_params.dart';

class ReqWithdrawMoneyToBank {
  num? amount;
  num? requestedAmount;
  int? accountId;

  ReqWithdrawMoneyToBank({this.amount, this.requestedAmount, this.accountId});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.amount] = amount;
    data[DicParams.requestedAmount] = requestedAmount;
    data[DicParams.accountId] = accountId;
    return data;
  }
}
