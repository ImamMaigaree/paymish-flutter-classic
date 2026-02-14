import '../../../../apis/dic_params.dart';

import 'res_my_documents.dart';

class ResUploadDocument {
  String? message;
  MyDocumentsModel? data;

  ResUploadDocument({this.message, this.data});

  ResUploadDocument.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    data = json[DicParams.data] != null
        ? MyDocumentsModel.fromJson(json[DicParams.data])
        : null;
  }
}
