import '../../../../apis/dic_params.dart';

class ReqIgreeKycExchange {
  int? userId;
  String? sessionId;
  String? code;
  String? bvnNumber;

  ReqIgreeKycExchange({
    this.userId,
    this.sessionId,
    this.code,
    this.bvnNumber,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.userId] = userId;
    data[DicParams.sessionId] = sessionId;
    data[DicParams.code] = code;
    data[DicParams.bvnNumber] = bvnNumber;
    return data;
  }
}
