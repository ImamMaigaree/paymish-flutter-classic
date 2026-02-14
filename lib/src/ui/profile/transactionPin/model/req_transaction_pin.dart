import '../../../../apis/dic_params.dart';

class ReqTransactionPin {
  String? transactionPin;

  ReqTransactionPin({this.transactionPin});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.transactionPin] = transactionPin;
    return data;
  }
}
