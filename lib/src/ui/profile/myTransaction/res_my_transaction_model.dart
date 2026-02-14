import '../../../apis/dic_params.dart';

class ResMyTransactionModel {
  TransactionData? _data;

  TransactionData? get data => _data;

  ResMyTransactionModel({TransactionData? data}) {
    _data = data;
  }

  ResMyTransactionModel.fromJson(dynamic json) {
    _data = json[DicParams.data] != null
        ? TransactionData.fromJson(json[DicParams.data])
        : null;
  }
}

class TransactionData {
  List<TransactionDataItem>? _result;
  int? _count;

  List<TransactionDataItem>? get result => _result;

  int? get count => _count;

  TransactionData({List<TransactionDataItem>? result, int? count}) {
    _result = result;
    _count = count;
  }

  TransactionData.fromJson(dynamic json) {
    if (json[DicParams.result] != null) {
      _result = [];
      json[DicParams.result].forEach((v) {
        _result?.add(TransactionDataItem.fromJson(v));
      });
    }
    _count = json[DicParams.count];
  }
}

class TransactionDataItem {
  String? _transactionId;
  String? _senderFirstName;
  String? _senderLastName;
  String? _receiverFirstName;
  String? _receiverLastName;
  String? _senderProfilePicture;
  String? _receiverProfilePicture;
  String? _utilityName;
  String? _utilityImage;
  num? _amount;
  String? _status;
  String? _createdAt;
  String? _type;

  String? get transactionId => _transactionId;

  String? get senderFirstName => _senderFirstName;

  String? get senderLastName => _senderLastName;

  String? get receiverFirstName => _receiverFirstName;

  String? get receiverLastName => _receiverLastName;

  String? get senderProfilePicture => _senderProfilePicture;

  String? get receiverProfilePicture => _receiverProfilePicture;
  String? get utilityName => _utilityName;
  String? get utilityImage => _utilityImage;

  num? get amount => _amount;

  String? get createdAt => _createdAt;

  String? get type => _type;
  String? get status => _status;

  TransactionDataItem(
      {String? transactionId,
      String? senderFirstName,
      String? senderLastName,
      String? receiverFirstName,
      String? receiverLastName,
      String? senderProfilePicture,
      String? receiverProfilePicture,
      String? utilityImage,
      String? utilityName,
      String? status,
      num? amount,
      String? createdAt,
      String? type}) {
    _transactionId = transactionId;
    _senderFirstName = senderFirstName;
    _senderLastName = senderLastName;
    _receiverFirstName = receiverFirstName;
    _receiverLastName = receiverLastName;
    _senderProfilePicture = senderProfilePicture;
    _receiverProfilePicture = receiverProfilePicture;
    _utilityName = utilityName;
    _utilityImage = utilityImage;
    _amount = amount;
    _createdAt = createdAt;
    _status = status;
    _type = type;
  }

  TransactionDataItem.fromJson(dynamic json) {
    _transactionId = json[DicParams.transactionId];
    _senderFirstName = json[DicParams.senderFirstName];
    _senderLastName = json[DicParams.senderLastName];
    _receiverFirstName = json[DicParams.receiverFirstName];
    _receiverLastName = json[DicParams.receiverLastName];
    _senderProfilePicture = json[DicParams.senderProfilePicture];
    _receiverProfilePicture = json[DicParams.receiverProfilePicture];
    _amount = json[DicParams.amount];
    _utilityName = json[DicParams.utilityName];
    _utilityImage = json[DicParams.utilityImage];
    _createdAt = json[DicParams.createdAt];
    _type = json[DicParams.type];
    _status = json[DicParams.status];
  }
}
