import '../../../../apis/dic_params.dart';

class ReqAddDevice {
  String? deviceType;
  String? deviceToken;
  String? timeZone;
  String? browserInfo;
  double? lat;
  double? long;

  ReqAddDevice(
      {this.deviceType,
      this.deviceToken,
      this.timeZone,
      this.browserInfo,
      this.lat,
      this.long});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.deviceType] = deviceType;
    data[DicParams.deviceToken] = deviceToken;
    data[DicParams.timeZone] = timeZone;
    data[DicParams.browserInfo] = browserInfo;
    data[DicParams.lat] = lat;
    data[DicParams.long] = long;
    return data;
  }
}
