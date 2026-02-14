import '../../../apis/dic_params.dart';

class ReqAccountSetting {
  int? isEmailNotification;
  int? isPushNotification;

  ReqAccountSetting({this.isEmailNotification, this.isPushNotification});

  ReqAccountSetting.fromJson(Map<String, dynamic> json) {
    isEmailNotification = json[DicParams.isEmailNotification];
    isPushNotification = json[DicParams.isPushNotification];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.isEmailNotification] = isEmailNotification;
    data[DicParams.isPushNotification] = isPushNotification;
    return data;
  }
}
