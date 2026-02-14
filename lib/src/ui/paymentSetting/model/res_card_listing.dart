class ResCardListing {
  List<CardDetails>? data;

  ResCardListing({this.data});

  ResCardListing.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CardDetails>[];
      json['data'].forEach((v) {
        data?.add(CardDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}

class CardDetails {
  int? id;
  String? maskedCardNo;
  String? bank;
  String? expiry;
  int? isDefault;
  String? cardHolderName;

  CardDetails(
      {this.id,
        this.maskedCardNo,
        this.bank,
        this.expiry,
        this.isDefault,
        this.cardHolderName});

  CardDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    maskedCardNo = json['maskedCardNo'];
    bank = json['bank'];
    expiry = json['expiry'];
    isDefault = json['isDefault'];
    cardHolderName = json['cardHolderName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['maskedCardNo'] = maskedCardNo;
    data['bank'] = bank;
    data['expiry'] = expiry;
    data['isDefault'] = isDefault;
    data['cardHolderName'] = cardHolderName;
    return data;
  }
}
