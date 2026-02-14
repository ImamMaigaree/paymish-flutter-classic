class ResDataPlanList {
  List<DataPlanItem>? data;

  ResDataPlanList({this.data});

  ResDataPlanList.fromJson(Map<String, dynamic> json) {
    data = <DataPlanItem>[];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        data!.add(DataPlanItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}

class DataPlanItem {
  String? identifier;
  String? serviceID;
  String? variationCode;
  String? vairationName;
  String? variationAmount;
  String? fixedPrice;

  DataPlanItem(
      {this.identifier,
      this.serviceID,
      this.variationCode,
      this.vairationName,
      this.variationAmount,
      this.fixedPrice});

  DataPlanItem.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier']?.toString();
    serviceID = json['serviceID']?.toString();
    variationCode = json['variation_code']?.toString();
    vairationName = json['vairation_name']?.toString();
    variationAmount = json['variation_amount']?.toString();
    fixedPrice = json['fixedPrice']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['serviceID'] = serviceID;
    data['variation_code'] = variationCode;
    data['vairation_name'] = vairationName;
    data['variation_amount'] = variationAmount;
    data['fixedPrice'] = fixedPrice;
    return data;
  }
}
