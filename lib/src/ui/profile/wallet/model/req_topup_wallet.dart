import '../../../../apis/dic_params.dart';

class ReqTopUpWallet {
  String? paidFrom;
  String? reference;
  String? status;
  num? amount;
  int? cardId;

  ReqTopUpWallet({this.paidFrom, this.amount,this.cardId,this.status,this.reference});

  ReqTopUpWallet.fromJson(Map<String, dynamic> json) {
    paidFrom = json[DicParams.paidFrom];
    amount = json[DicParams.amount];
    cardId = json[DicParams.cardId];
    status = json[DicParams.status];
    reference = json[DicParams.reference];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.paidFrom] = paidFrom;
    data[DicParams.amount] = amount;
    data[DicParams.cardId] = cardId;
    data[DicParams.reference] = reference;
    data[DicParams.status] = status;
    return data;
  }
}
