import '../../../../../apis/dic_params.dart';

class ResChangePin {
  String? message;

  ResChangePin({this.message});

  ResChangePin.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.message] = message;
    return data;
  }
}
