import '../../../../apis/base_model.dart';
import '../../../../apis/dic_params.dart';

class ResIgreeKycStart extends ResBaseModel {
  IgreeKycStartData? data;

  ResIgreeKycStart.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = json[DicParams.data] != null
        ? IgreeKycStartData.fromJson(json[DicParams.data])
        : null;
  }
}

class IgreeKycStartData {
  String? sessionId;
  String? provider;
  String? status;
  String? authorizationUrl;

  IgreeKycStartData({
    this.sessionId,
    this.provider,
    this.status,
    this.authorizationUrl,
  });

  IgreeKycStartData.fromJson(Map<String, dynamic> json) {
    sessionId = json[DicParams.sessionId]?.toString();
    provider = json[DicParams.provider]?.toString();
    status = json[DicParams.status]?.toString();
    authorizationUrl = json[DicParams.authorizationUrl]?.toString();
  }
}
