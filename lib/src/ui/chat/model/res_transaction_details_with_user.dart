import '../../../apis/dic_params.dart';

class ResTransactionDetailsWithUser {
  Data? data;

  ResTransactionDetailsWithUser({this.data});

  ResTransactionDetailsWithUser.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }
}

class Data {
  List<ResTransactionDetailsItem>? result;
  int? count;

  Data({this.result, this.count});

  Data.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.result] != null) {
      result = <ResTransactionDetailsItem>[];
      json[DicParams.result].forEach((v) {
        result?.add(ResTransactionDetailsItem.fromJson(v));
      });
    }
    count = json[DicParams.count];
  }
}

class ResTransactionDetailsItem {
  int? id;
  String? message;
  String? type;
  int? senderId;
  int? receiverId;
  String? createdAt;
  String? requestStatus;
  String? senderFirstName;
  String? senderLastName;
  String? receiverFirstName;
  String? receiverLastName;
  num? requestedAmount;
  int? requestId;
  num? transactionAmount;
  String? transactionStatus;
  String? receiverProfilePicture;
  String? senderProfilePicture;

  ResTransactionDetailsItem(
      {this.id,
      this.message,
      this.type,
      this.senderId,
      this.receiverId,
      this.createdAt,
      this.requestStatus,
      this.senderFirstName,
      this.receiverFirstName,
      this.receiverLastName,
      this.senderLastName,
      this.requestedAmount,
      this.requestId,
      this.transactionAmount,
      this.transactionStatus,
      this.receiverProfilePicture,
      this.senderProfilePicture});

  ResTransactionDetailsItem.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    message = json[DicParams.message];
    type = json[DicParams.type];
    senderId = json[DicParams.senderId];
    receiverId = json[DicParams.receiverId];
    createdAt = json[DicParams.createdAt];
    requestStatus = json[DicParams.requestStatus];
    senderFirstName = json[DicParams.senderFirstName];
    receiverFirstName = json[DicParams.receiverFirstName];
    requestedAmount = json[DicParams.requestedAmount];
    requestId = json[DicParams.requestId];
    senderLastName = json[DicParams.senderLastName];
    receiverLastName = json[DicParams.receiverLastName];
    transactionAmount = json[DicParams.transactionAmount];
    transactionStatus = json[DicParams.transactionStatus];
    receiverProfilePicture = json[DicParams.receiverProfilePicture];
    senderProfilePicture = json[DicParams.senderProfilePicture];
  }
}
