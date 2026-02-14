import '../../../apis/dic_params.dart';

class ReqCreateSupportTicket {
  int? supportCategoryId;
  String? title;
  String? description;

  ReqCreateSupportTicket(
      {this.supportCategoryId, this.title, this.description});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.supportCategoryId] = supportCategoryId;
    data[DicParams.title] = title;
    data[DicParams.description] = description;
    return data;
  }
}
