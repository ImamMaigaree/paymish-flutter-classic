import '../../../apis/dic_params.dart';

class ReqApproveRequest {
  String? payFrom;
  String? remarks;
  int? requestId;
  int? cardId;
  String? reference;
  String? status;

  ReqApproveRequest(
      {this.payFrom,
      this.remarks,
      this.requestId,
      this.cardId,
      this.reference,
      this.status});

  ReqApproveRequest.fromJson(Map<String, dynamic> json) {
    payFrom = json[DicParams.payFrom];
    remarks = json[DicParams.remarks];
    requestId = json[DicParams.requestId];
    cardId = json[DicParams.cardId];
    reference = json[DicParams.reference];
    status = json[DicParams.status];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.payFrom] = payFrom;
    data[DicParams.remarks] = remarks;
    data[DicParams.requestId] = requestId;
    data[DicParams.cardId] = cardId;
    data[DicParams.reference] = reference;
    data[DicParams.status] = status;
    return data;
  }
}
