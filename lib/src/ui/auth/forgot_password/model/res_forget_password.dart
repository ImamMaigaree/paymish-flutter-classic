import '../../../../apis/dic_params.dart';

class ResForgetPassword {
  String? message;
  ResForgotPasswordData? data;

  ResForgetPassword({this.message, this.data});

  ResForgetPassword.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message]?.toString();
    data = json[DicParams.data] != null
        ? ResForgotPasswordData.fromJson(json[DicParams.data])
        : null;
  }
}

class ResForgotPasswordData {
  int? userId;
  String? type;

  ResForgotPasswordData({this.userId, this.type});

  ResForgotPasswordData.fromJson(Map<String, dynamic> json) {
    userId = json[DicParams.userId];
    type = json[DicParams.type];
  }
}
