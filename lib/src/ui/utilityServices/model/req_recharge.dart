class ReqRechargeModel {
  String? mobile;
  String? serviceID;
  num? amount;
  String? type;
  String? paidFrom;
  String? variationCode;
  String? billersCode;
  String? reference;
  String? status;
  int? cardId;

  ReqRechargeModel(
      {this.mobile,
      this.serviceID,
      this.amount,
      this.type,
      this.paidFrom,
      this.billersCode,
      this.reference,
      this.status,
      this.cardId,
      this.variationCode});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mobile'] = mobile;
    data['serviceID'] = serviceID;
    data['amount'] = amount;
    data['type'] = type;
    data['paidFrom'] = paidFrom;
    data['variation_code'] = variationCode;
    data['billersCode'] = billersCode;
    data['reference'] = reference;
    data['status'] = status;
    data['cardId'] = cardId;
    return data;
  }
}
