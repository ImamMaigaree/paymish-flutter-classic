import '../../../../apis/dic_params.dart';

class ResTopUpWallet {
  String? message;

  ResTopUpWallet({this.message});

  ResTopUpWallet.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.message] = message;
    return data;
  }
}
