import '../../../../apis/dic_params.dart';

class ReqAccessCode {
  String? email;
  String? amount;

  ReqAccessCode({this.email,this.amount});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.email] = email;
    data[DicParams.amount] = amount;
    return data;
  }
}
