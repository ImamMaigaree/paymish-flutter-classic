import '../../../apis/dic_params.dart';

class ResBankDetails {
  List<BankDetail>? data;

  ResBankDetails({this.data});

  ResBankDetails.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.data] != null) {
      data = <BankDetail>[];
      json[DicParams.data].forEach((v) {
        data?.add(BankDetail.fromJson(v));
      });
    }
  }
}

class BankDetail {
  int? id;
  String? bankName;
  String? maskedAccountNumber;
  String? accountType;
  int? isDefault;

  BankDetail(
      {this.id,
      this.bankName,
      this.maskedAccountNumber,
      this.accountType,
      this.isDefault});

  BankDetail.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    bankName = json[DicParams.bankName];
    maskedAccountNumber = json[DicParams.maskedAccountNumber];
    accountType = json[DicParams.accountType];
    isDefault = json[DicParams.isDefault];
  }
}
