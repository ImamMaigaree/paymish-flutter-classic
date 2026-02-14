import '../../../../apis/dic_params.dart';

class ResSupportTicket {
  SupportTicketData? data;

  ResSupportTicket({this.data});

  ResSupportTicket.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? SupportTicketData.fromJson(json[DicParams.data])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      data[DicParams.data] = this.data!.toJson();
    }
    return data;
  }
}

class SupportTicketData {
  List<SupportTicketDetails>? result;
  int? count;

  SupportTicketData({this.result, this.count});

  SupportTicketData.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.result] != null) {
      result = <SupportTicketDetails>[];
      json[DicParams.result].forEach((v) {
        result?.add(SupportTicketDetails.fromJson(v));
      });
    }
    count = json[DicParams.count];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.result] = result?.map((v) => v.toJson()).toList() ?? [];
    data[DicParams.count] = count;
    return data;
  }
}

class SupportTicketDetails {
  int? id;
  String? title;
  String? description;
  String? status;
  String? createdAt;
  String? category;

  SupportTicketDetails(
      {this.id,
      this.title,
      this.description,
      this.status,
      this.createdAt,
      this.category});

  SupportTicketDetails.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    title = json[DicParams.title];
    description = json[DicParams.description];
    status = json[DicParams.status];
    createdAt = json[DicParams.createdAt];
    category = json[DicParams.category];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.id] = id;
    data[DicParams.title] = title;
    data[DicParams.description] = description;
    data[DicParams.status] = status;
    data[DicParams.createdAt] = createdAt;
    data[DicParams.category] = category;
    return data;
  }
}
