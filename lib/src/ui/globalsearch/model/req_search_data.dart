import '../../../apis/dic_params.dart';

class ReqSearchModel {
  String? keyword;

  ReqSearchModel({this.keyword});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.keyword] = keyword;
    return data;
  }
}
