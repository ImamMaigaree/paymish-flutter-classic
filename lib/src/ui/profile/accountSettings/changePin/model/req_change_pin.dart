import '../../../../../apis/dic_params.dart';

class ReqChangePin {
  String? transactionPin;
  String? newTransactionPin;

  ReqChangePin({this.transactionPin, this.newTransactionPin});

  ReqChangePin.fromJson(Map<String, dynamic> json) {
    transactionPin = json[DicParams.transactionPin];
    newTransactionPin = json[DicParams.newTransactionPin];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.transactionPin] = transactionPin;
    data[DicParams.newTransactionPin] = newTransactionPin;
    return data;
  }
}
