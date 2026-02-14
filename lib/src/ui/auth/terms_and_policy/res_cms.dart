import '../../../apis/dic_params.dart';

class ResCMS {
  String? message;
  List<CMSData>? data;

  ResCMS({this.message, this.data});

  ResCMS.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    if (json[DicParams.data] != null) {
      data = <CMSData>[];
      json[DicParams.data].forEach((v) {
        data?.add(CMSData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.message] = message;
    data[DicParams.data] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}

class CMSData {
  String? title;
  String? slug;
  String? content;

  CMSData({this.title, this.slug, this.content});

  CMSData.fromJson(Map<String, dynamic> json) {
    title = json[DicParams.title];
    slug = json[DicParams.slug];
    content = json[DicParams.content];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.title] = title;
    data[DicParams.slug] = slug;
    data[DicParams.content] = content;
    return data;
  }
}
