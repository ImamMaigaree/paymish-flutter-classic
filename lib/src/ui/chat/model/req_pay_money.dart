import '../../../apis/dic_params.dart';

class ReqPayMoney {
  String? paidFrom;
  num? amount;
  String? remarks;
  String? reference;
  String? status;
  int? payingTo;
  int? cardId;

  ReqPayMoney(
      {this.paidFrom,
      this.amount,
      this.remarks,
      this.payingTo,
      this.cardId,
      this.reference,
      this.status});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.paidFrom] = paidFrom;
    data[DicParams.amount] = amount;
    data[DicParams.remarks] = remarks;
    data[DicParams.payingTo] = payingTo;
    data[DicParams.cardId] = cardId;
    data[DicParams.reference] = reference;
    data[DicParams.status] = status;
    return data;
  }
}
