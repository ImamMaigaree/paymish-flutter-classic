import '../../../../apis/dic_params.dart';

class ReqLogin {
  String? mobile;
  String? password;
  String? userType;
  int? deviceId;

  ReqLogin({this.mobile, this.password, this.userType, this.deviceId});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.mobile] = mobile;
    data[DicParams.password] = password;
    data[DicParams.userType] = userType;
    data[DicParams.deviceId] = deviceId;
    return data;
  }
}
