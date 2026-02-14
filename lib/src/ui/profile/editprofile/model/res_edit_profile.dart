import '../../../../apis/dic_params.dart';

class ResEditProfile {
  String? message;
  ResponseProfileChange? data;

  ResEditProfile({this.message, this.data});

  ResEditProfile.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    data = json[DicParams.data] != null
        ? ResponseProfileChange.fromJson(json[DicParams.data])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.message] = message;
    data[DicParams.data] = this.data?.toJson();
    return data;
  }
}

class ResponseProfileChange {
  int? isEmailChanged;
  int? isMobileChanged;

  ResponseProfileChange({this.isEmailChanged, this.isMobileChanged});

  ResponseProfileChange.fromJson(Map<String, dynamic> json) {
    isEmailChanged = json[DicParams.isEmailChanged];
    isMobileChanged = json[DicParams.isMobileChanged];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.isEmailChanged] = isEmailChanged;
    data[DicParams.isMobileChanged] = isMobileChanged;
    return data;
  }
}
