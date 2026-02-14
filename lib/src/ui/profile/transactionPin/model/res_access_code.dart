import '../../../../apis/dic_params.dart';

class ResAccessCode {
  Data? data;

  ResAccessCode({this.data});

  ResAccessCode.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  String? accessCode;

  Data({this.accessCode});

  Data.fromJson(Map<String, dynamic> json) {
    accessCode = json[DicParams.accessCode];
  }
}
