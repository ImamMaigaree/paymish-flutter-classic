import '../../../../apis/dic_params.dart';

class ResWalletSetup {
  String? message;
  Data? data;

  ResWalletSetup({this.message, this.data});

  ResWalletSetup.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }
}

class Data {
  int? id;
  String? bankName;
  String? maskedAccountNumber;

  Data({this.id, this.bankName, this.maskedAccountNumber});

  Data.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    bankName = json[DicParams.bankName];
    maskedAccountNumber = json[DicParams.maskedAccountNumber];
  }
}
