import '../../../../apis/base_model.dart';
import '../../../../apis/dic_params.dart';

class ResIgreeKycExchange extends ResBaseModel {
  IgreeKycExchangeData? data;

  ResIgreeKycExchange.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    data = json[DicParams.data] != null
        ? IgreeKycExchangeData.fromJson(json[DicParams.data])
        : null;
  }
}

class IgreeKycExchangeData {
  String? provider;
  String? sessionId;
  String? status;
  String? kycStatus;
  String? bvnNumber;

  IgreeKycExchangeData({
    this.provider,
    this.sessionId,
    this.status,
    this.kycStatus,
    this.bvnNumber,
  });

  IgreeKycExchangeData.fromJson(Map<String, dynamic> json) {
    provider = json[DicParams.provider]?.toString();
    sessionId = json[DicParams.sessionId]?.toString();
    status = json[DicParams.status]?.toString();
    kycStatus = json[DicParams.kycStatus]?.toString();
    bvnNumber = json[DicParams.bvnNumber]?.toString();
  }
}
