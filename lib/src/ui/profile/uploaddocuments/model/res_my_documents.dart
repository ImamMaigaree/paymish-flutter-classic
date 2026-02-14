import '../../../../apis/dic_params.dart';

class ResMyDocumentsModel {
  String? message;
  List<MyDocumentsModel>? data;

  ResMyDocumentsModel({this.message, this.data});

  ResMyDocumentsModel.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    if (json[DicParams.data] != null) {
      data = <MyDocumentsModel>[];
      json[DicParams.data].forEach((v) {
        data?.add(MyDocumentsModel.fromJson(v));
      });
    }
  }
}

class MyDocumentsModel {
  int? id;
  String? documentType;
  String? document;
  String? type;
  int? isApproved;

  MyDocumentsModel(
      {this.id, this.documentType, this.document, this.type, this.isApproved});

  MyDocumentsModel.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    documentType = json[DicParams.documentType];
    document = json[DicParams.document];
    type = json[DicParams.type];
    isApproved = json[DicParams.isApproved];
  }
}
