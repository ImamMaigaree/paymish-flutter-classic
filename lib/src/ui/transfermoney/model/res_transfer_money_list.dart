class ResTransferMoneyList {
  ResTransferData? data;

  ResTransferMoneyList({this.data});

  ResTransferMoneyList.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? ResTransferData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ResTransferData {
  List<TransferMoneyListData>? result;
  int? count;

  ResTransferData({this.result, this.count});

  ResTransferData.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <TransferMoneyListData>[];
      json['result'].forEach((v) {
        result?.add(TransferMoneyListData.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result?.map((v) => v.toJson()).toList() ?? [];
    data['count'] = count;
    return data;
  }
}

class TransferMoneyListData {
  int? id;
  int? requestBy;
  String? status;
  String? lastName;
  String? mobile;
  String? profilePicture;
  String? requestedAt;
  String? paymentMethod;
  String? firstName;
  num? amount;
  String? remarks;
  int? cardId;

  TransferMoneyListData(
      {this.id,
      this.requestBy,
      this.status,
      this.lastName,
      this.mobile,
      this.profilePicture,
      this.requestedAt,
      this.paymentMethod,
      this.firstName,
      this.amount,
      this.cardId,
      this.remarks});

  TransferMoneyListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestBy = json['requestBy'];
    status = json['status'];
    lastName = json['lastName'];
    mobile = json['mobile'];
    profilePicture = json['profilePicture'];
    requestedAt = json['requestedAt'];
    paymentMethod = json['paymentMethod'];
    firstName = json['firstName'];
    amount = json['amount'];
    cardId = json['cardId'];
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['requestBy'] = requestBy;
    data['status'] = status;
    data['lastName'] = lastName;
    data['mobile'] = mobile;
    data['profilePicture'] = profilePicture;
    data['requestedAt'] = requestedAt;
    data['paymentMethod'] = paymentMethod;
    data['firstName'] = firstName;
    data['amount'] = amount;
    data['remarks'] = remarks;
    data['cardId'] = cardId;
    return data;
  }
}
