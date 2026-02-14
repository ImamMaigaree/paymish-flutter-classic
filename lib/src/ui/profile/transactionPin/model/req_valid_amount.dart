import '../../../../apis/dic_params.dart';

class ReqValidAmount {
  num? amount;
  String? payingTo;

  ReqValidAmount({this.amount, this.payingTo});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.amount] = amount;
    data[DicParams.payingTo] = payingTo;
    return data;
  }
}
