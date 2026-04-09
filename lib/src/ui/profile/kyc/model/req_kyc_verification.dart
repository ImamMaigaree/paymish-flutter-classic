import '../../../../apis/dic_params.dart';

class ReqKycVerification {
  String? bvnNumber;

  ReqKycVerification({this.bvnNumber});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.bvnNumber] = bvnNumber;
    return data;
  }
}
