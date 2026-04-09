import 'dic_params.dart';

class ResBaseModel {
  String? error;
  int? code;
  String? message;
  ErrorLogin? errorLogin;

  ResBaseModel({this.error, this.code});

  ResBaseModel.fromJson(Map<String, dynamic> json) {
    error = json[DicParams.error]?.toString();
    code = json[DicParams.code];
    message = json[DicParams.message]?.toString();
  }

  ResBaseModel.fromJsonWithCode(response) {
    error = response.data[DicParams.error]?.toString();
    code = response.statusCode;
    message = response.data[DicParams.message]?.toString();
    errorLogin = response.data[DicParams.data] != null
        ? ErrorLogin.fromJson(response.data[DicParams.data])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.error] = error;
    data[DicParams.code] = code;
    data[DicParams.message] = message;
    return data;
  }
}

class ErrorLogin {
  int? isMobileVerified;
  int? isEmailVerified;

  ErrorLogin({this.isMobileVerified, this.isEmailVerified});

  ErrorLogin.fromJson(Map<String, dynamic> json) {
    isMobileVerified = json['isMobileVerified'];
    isEmailVerified = json['isEmailVerified'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isMobileVerified'] = isMobileVerified;
    data['isEmailVerified'] = isEmailVerified;
    return data;
  }
}
