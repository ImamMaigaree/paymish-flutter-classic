import '../../../../../apis/dic_params.dart';

class ReqVerifyOtp {
  String? type;
  String? otp;
  String? mobile;

  ReqVerifyOtp({this.type, this.otp, this.mobile});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.type] = type;
    data[DicParams.otp] = otp;
    data[DicParams.mobile] = mobile;
    return data;
  }
}
