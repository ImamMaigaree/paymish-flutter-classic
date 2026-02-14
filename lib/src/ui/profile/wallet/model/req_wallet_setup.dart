import '../../../../apis/dic_params.dart';

class ReqWalletSetup {
  String? bankName;
  String? fsiAccountNumber;
  String? code;
  String? bankHolderName;

  ReqWalletSetup(
      {this.bankName, this.fsiAccountNumber, this.code, this.bankHolderName});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.bankName] = bankName;
    data[DicParams.fsiAccountNumber] = fsiAccountNumber;
    data[DicParams.code] = code;
    data[DicParams.bankHolderName] = bankHolderName;
    return data;
  }
}
