import '../../../../apis/dic_params.dart';

class ResNotification {
  Data? data;

  ResNotification({this.data});

  ResNotification.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }
}

class Data {
  List<NotificationListData>? result;
  int? count;
  int? unReadCount;

  Data({this.result, this.count, this.unReadCount});

  Data.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.result] != null) {
      result = <NotificationListData>[];
      json[DicParams.result].forEach((v) {
        result!.add(NotificationListData.fromJson(v));
      });
    }
    count = json[DicParams.count];
    unReadCount = json[DicParams.unReadCount];
  }
}

class NotificationListData {
  String? category;
  String? title;
  String? body;
  int? isRead;
  int? senderId;
  int? ticketId;
  String? createdAt;
  int? id;

  NotificationListData(
      {this.category,
      this.title,
      this.body,
      this.isRead,
      this.senderId,
      this.ticketId,
      this.createdAt,
      this.id});

  NotificationListData.fromJson(Map<String, dynamic> json) {
    category = json[DicParams.category];
    title = json[DicParams.title];
    body = json[DicParams.body];
    isRead = json[DicParams.isRead];
    senderId = json[DicParams.senderId];
    ticketId = json[DicParams.ticketId];
    createdAt = json[DicParams.createdAt];
    id = json[DicParams.id];
  }
}
