import '../../../../apis/dic_params.dart';

class ReqIgreeKycStart {
  int? userId;
  String? bvnNumber;

  ReqIgreeKycStart({this.userId, this.bvnNumber});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.userId] = userId;
    data[DicParams.bvnNumber] = bvnNumber;
    return data;
  }
}
