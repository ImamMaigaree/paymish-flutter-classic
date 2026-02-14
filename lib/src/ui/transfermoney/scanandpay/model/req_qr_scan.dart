import '../../../../apis/dic_params.dart';

class ReqQRScan {
  String? qrCode;

  ReqQRScan({this.qrCode});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.qrCode] = qrCode;
    return data;
  }
}
