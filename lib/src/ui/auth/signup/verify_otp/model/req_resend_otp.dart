import '../../../../../apis/dic_params.dart';

class ReqResendOtp {
  String? type;
  String? mobile;
  int? sendEmail;

  ReqResendOtp({this.type, this.mobile, this.sendEmail});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.type] = type;
    data[DicParams.mobile] = mobile;
    data[DicParams.sendEmail] = sendEmail;
    return data;
  }
}
