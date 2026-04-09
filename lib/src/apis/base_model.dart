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
    if (response == null) {
      error = 'Unable to reach 1Trust services. Please try again.';
      code = 0;
      message = error;
      return;
    }

    final responseData = response.data;
    final dataMap = responseData is Map<String, dynamic>
        ? responseData
        : <String, dynamic>{};

    error =
        dataMap[DicParams.error]?.toString() ??
        dataMap[DicParams.message]?.toString() ??
        response.statusMessage?.toString() ??
        'Request failed';
    code = response.statusCode;
    message = dataMap[DicParams.message]?.toString() ?? error;
    errorLogin = dataMap[DicParams.data] is Map<String, dynamic>
        ? ErrorLogin.fromJson(dataMap[DicParams.data] as Map<String, dynamic>)
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
