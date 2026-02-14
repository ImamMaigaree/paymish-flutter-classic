import '../../../apis/dic_params.dart';

class ResProfile {
  String? message;
  ProfileData? data;

  ResProfile({this.message, this.data});

  ResProfile.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    data = json[DicParams.data] != null
        ? ProfileData.fromJson(json[DicParams.data])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.message] = message;
    data[DicParams.data] = this.data?.toJson();
    return data;
  }
}

class ProfileData {
  int? id;
  String? firstName;
  String? lastName;
  String? bvnNumber;
  String? kycStatus;
  String? businessName;
  String? businessCategories;
  String? businessDescription;
  String? qrCode;
  String? role;
  String? countryCode;
  String? mobile;
  String? profilePicture;
  int? isEmailNotification;
  int? isPushNotification;

  ProfileData(
      {this.id,
      this.firstName,
      this.lastName,
      this.bvnNumber,
      this.kycStatus,
      this.businessName,
      this.businessCategories,
      this.businessDescription,
      this.isEmailNotification,
      this.isPushNotification,
      this.qrCode,
      this.role,
      this.countryCode,
      this.mobile,
      this.profilePicture});

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    bvnNumber = json[DicParams.bvnNumber];
    kycStatus = json[DicParams.kycStatus];
    businessName = json[DicParams.businessName];
    businessCategories = json[DicParams.businessCategories];
    businessDescription = json[DicParams.businessDescription];
    isEmailNotification = json[DicParams.isEmailNotification];
    isPushNotification = json[DicParams.isPushNotification];
    qrCode = json[DicParams.qrCode];
    role = json[DicParams.role];
    countryCode = json[DicParams.countryCode];
    mobile = json[DicParams.mobile];
    profilePicture = json[DicParams.profilePicture];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.id] = id;
    data[DicParams.firstName] = firstName;
    data[DicParams.lastName] = lastName;
    data[DicParams.bvnNumber] = bvnNumber;
    data[DicParams.kycStatus] = kycStatus;
    data[DicParams.businessName] = businessName;
    data[DicParams.businessCategories] = businessCategories;
    data[DicParams.businessDescription] = businessDescription;
    data[DicParams.qrCode] = qrCode;
    data[DicParams.role] = role;
    data[DicParams.countryCode] = countryCode;
    data[DicParams.mobile] = mobile;
    data[DicParams.profilePicture] = profilePicture;
    return data;
  }
}
