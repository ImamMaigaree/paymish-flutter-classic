import '../../../../../apis/dic_params.dart';

class ReqChangePassword {
  String? currentPassword;
  String? newPassword;

  ReqChangePassword({this.currentPassword, this.newPassword});

  ReqChangePassword.fromJson(Map<String, dynamic> json) {
    currentPassword = json[DicParams.currentPassword];
    newPassword = json[DicParams.newPassword];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.currentPassword] = currentPassword;
    data[DicParams.newPassword] = newPassword;
    return data;
  }
}
