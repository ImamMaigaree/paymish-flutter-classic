import '../../../../apis/base_model.dart';
import '../../../../apis/dic_params.dart';

class ResSignUp extends ResBaseModel {
  @override
  String? message;
  ResSignUpData? data;

  ResSignUp({this.message, this.data});

  ResSignUp.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    data = json[DicParams.data] != null
        ? ResSignUpData.fromJson(json[DicParams.data])
        : null;
  }
}

class ResSignUpData {
  int? id;

  ResSignUpData({this.id});

  ResSignUpData.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
  }
}
