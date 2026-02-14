class ReqMoney {
  int? requestTo;
  num? amount;
  String? paymentMethod;
  String? remarks;

  ReqMoney({this.requestTo, this.amount, this.paymentMethod, this.remarks});

  ReqMoney.fromJson(Map<String, dynamic> json) {
    requestTo = json['requestTo'];
    amount = json['amount'];
    paymentMethod = json['paymentMethod'];
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['requestTo'] = requestTo;
    data['amount'] = amount;
    if (paymentMethod != null) {
      data['paymentMethod'] = paymentMethod;
    }
    if (remarks != null) {
      data['remarks'] = remarks;
    }
    return data;
  }
}
