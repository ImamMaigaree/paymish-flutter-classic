import '../../../../apis/dic_params.dart';

class ReqTransactionPinValidation {
  String? transactionPin;

  ReqTransactionPinValidation({this.transactionPin});

  ReqTransactionPinValidation.fromJson(Map<String, dynamic> json) {
    transactionPin = json[DicParams.transactionPin];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.transactionPin] = transactionPin;
    return data;
  }
}
