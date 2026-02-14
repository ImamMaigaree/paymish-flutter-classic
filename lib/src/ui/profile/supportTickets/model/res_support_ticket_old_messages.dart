import '../../../../apis/dic_params.dart';

class ResSupportTicketOldMessage {
  Result? result;

  ResSupportTicketOldMessage({this.result});

  ResSupportTicketOldMessage.fromJson(Map<String, dynamic> json) {
    result = json[DicParams.result] != null
        ? Result.fromJson(json[DicParams.result])
        : null;
  }
}

class Result {
  TicketDetails? ticketDetails;
  List<SupportChatMessage>? message;
  int? totalRecords;

  Result({this.ticketDetails, this.message, this.totalRecords});

  Result.fromJson(Map<String, dynamic> json) {
    ticketDetails = json[DicParams.ticketDetails] != null
        ? TicketDetails.fromJson(json[DicParams.ticketDetails])
        : null;
    if (json[DicParams.message] != null) {
      message = <SupportChatMessage>[];
      json[DicParams.message].forEach((v) {
        message?.add(SupportChatMessage.fromJson(v));
      });
    }
    totalRecords = json[DicParams.totalRecords];
  }
}

class TicketDetails {
  int? id;
  String? title;
  String? description;
  String? status;
  String? createdAt;

  TicketDetails(
      {this.id, this.title, this.description, this.status, this.createdAt});

  TicketDetails.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    title = json[DicParams.title];
    description = json[DicParams.description];
    status = json[DicParams.status];
    createdAt = json[DicParams.createdAt];
  }
}

class SupportChatMessage {
  int? id;
  int? createdById;
  int? ticketId;
  String? message;
  String? createdAt;
  String? type;
  String? profilePicture;
  String? senderName;
  String? role;

  SupportChatMessage(
      {this.id,
      this.createdById,
      this.ticketId,
      this.message,
      this.createdAt,
      this.type,
      this.profilePicture,
      this.senderName,
      this.role});

  SupportChatMessage.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    createdById = json[DicParams.createdById];
    ticketId = json[DicParams.ticketId];
    message = json[DicParams.message];
    createdAt = json[DicParams.createdAt];
    type = json[DicParams.type];
    profilePicture = json[DicParams.profilePicture];
    senderName = json[DicParams.senderName];
    role = json[DicParams.role];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.id] = id;
    data[DicParams.createdById] = createdById;
    data[DicParams.ticketId] = ticketId;
    data[DicParams.message] = message;
    data[DicParams.createdAt] = createdAt;
    data[DicParams.type] = type;
    data[DicParams.profilePicture] = profilePicture;
    data[DicParams.senderName] = senderName;
    data[DicParams.role] = role;
    return data;
  }
}
