import '../../../../apis/dic_params.dart';

class ReqWithdrawMoneyToBank {
  num? amount;
  int? accountId;

  ReqWithdrawMoneyToBank({this.amount, this.accountId});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.amount] = amount;
    data[DicParams.accountId] = accountId;
    return data;
  }
}
