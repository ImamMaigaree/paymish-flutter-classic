import '../../../../apis/dic_params.dart';

class ResAddDevice {
  int? deviceId;

  ResAddDevice({this.deviceId});

  ResAddDevice.fromJson(Map<String, dynamic> json) {
    deviceId = json[DicParams.deviceId];
  }
}
