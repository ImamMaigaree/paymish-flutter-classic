import '../../../../apis/base_model.dart';
import '../../../../apis/dic_params.dart';

class ResLogin extends ResBaseModel {
  User? user;
  String? token;

  ResLogin({this.user, this.token});

  ResLogin.fromJson(Map<String, dynamic> json) {
    user = json[DicParams.user] != null
        ? User.fromJson(json[DicParams.user])
        : null;
    token = json[DicParams.token];
  }
}

class User {
  int? id;
  String? mobile;
  String? role;
  String? email;
  String? businessName;
  String? firstName;
  String? lastName;
  String? qrCode;
  String? kycStatus;
  int? isTransactionPin;
  int? isBankAccount;
  String? profilePicture;
  String? businessCategories;
  String? businessDescription;
  String? bvnNumber;
  int? deviceId;
  int? isApprovedByAdmin;
  bool? isDocumentUploaded;

  User(
      {this.id,
      this.mobile,
      this.role,
      this.email,
      this.businessName,
      this.firstName,
      this.lastName,
      this.qrCode,
      this.kycStatus,
      this.isTransactionPin,
      this.isBankAccount,
      this.profilePicture,
      this.businessCategories,
      this.businessDescription,
      this.bvnNumber,
      this.deviceId,
      this.isApprovedByAdmin,
      this.isDocumentUploaded});

  User.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    mobile = json[DicParams.mobile];
    role = json[DicParams.role];
    email = json[DicParams.email];
    businessName = json[DicParams.businessName];
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    qrCode = json[DicParams.qrCode];
    kycStatus = json[DicParams.kycStatus];
    isTransactionPin = json[DicParams.isTransactionPin];
    isBankAccount = json[DicParams.isBankAccount];
    profilePicture = json[DicParams.profilePicture];
    businessCategories = json[DicParams.businessCategories];
    businessDescription = json[DicParams.businessDescription];
    bvnNumber = json[DicParams.bvnNumber];
    deviceId = json[DicParams.deviceId];
    isApprovedByAdmin = json[DicParams.isApprovedByAdmin];
    isDocumentUploaded = json[DicParams.isDocumentUploaded];
  }
}
