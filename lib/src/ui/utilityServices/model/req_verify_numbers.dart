import '../../../apis/dic_params.dart';

class ReqVerifyNumbers {
  String? billersCode;
  String? serviceID;
  String? variationCode;

  ReqVerifyNumbers({this.billersCode, this.serviceID, this.variationCode});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.billersCode] = billersCode;
    data[DicParams.serviceID] = serviceID;
    data[DicParams.variation_code] = variationCode;
    return data;
  }
}
