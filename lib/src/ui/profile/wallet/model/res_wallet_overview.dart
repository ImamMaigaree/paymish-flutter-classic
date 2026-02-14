import '../../../../apis/dic_params.dart';

class ResWalletOverview {
  Data? data;

  ResWalletOverview({this.data});

  ResWalletOverview.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      data[DicParams.data] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? firstName;
  String? lastName;
  String? qrCode;
  num? walletBalance;

  Data({this.firstName, this.lastName, this.qrCode, this.walletBalance});

  Data.fromJson(Map<String, dynamic> json) {
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    qrCode = json[DicParams.qrCode];
    walletBalance = json[DicParams.walletBalance];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.firstName] = firstName;
    data[DicParams.lastName] = lastName;
    data[DicParams.qrCode] = qrCode;
    data[DicParams.walletBalance] = walletBalance;
    return data;
  }
}
