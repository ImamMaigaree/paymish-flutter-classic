import '../../../../../apis/dic_params.dart';

class ResChangePassword {
  String? message;

  ResChangePassword({this.message});

  ResChangePassword.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.message] = message;
    return data;
  }
}
