import '../../../../apis/dic_params.dart';

class ReqResetPassword {
  int? userId;
  String? password;

  ReqResetPassword({this.userId, this.password});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.userId] = userId;
    data[DicParams.password] = password;
    return data;
  }
}
