import '../../../../apis/dic_params.dart';

class ResValidAmount {
  Data? data;

  ResValidAmount({this.data});

  ResValidAmount.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  int? isValid;

  Data({this.isValid});

  Data.fromJson(Map<String, dynamic> json) {
    isValid = json[DicParams.isValid];
  }
}
