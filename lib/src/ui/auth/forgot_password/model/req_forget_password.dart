import '../../../../apis/dic_params.dart';

class ReqForgetPassword {
  String? mobile;
  String? email;

  ReqForgetPassword({this.mobile, this.email});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.mobile] = mobile;
    data[DicParams.email] = email;
    return data;
  }
}
