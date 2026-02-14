import '../../../../apis/dic_params.dart';

class ResQRScan {
  QRScanData? data;

  ResQRScan({this.data});

  ResQRScan.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? QRScanData.fromJson(json[DicParams.data])
        : null;
  }
}

class QRScanData {
  int? id;
  String? email;
  String? mobile;
  String? firstName;
  String? lastName;
  String? businessName;
  String? role;
  String? isApprovedByAdmin;
  String? profilePicture;

  QRScanData(
      {this.id,
      this.email,
      this.mobile,
      this.firstName,
      this.lastName,
      this.businessName,
      this.role,
      this.isApprovedByAdmin,
      this.profilePicture});

  QRScanData.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    email = json[DicParams.email];
    mobile = json[DicParams.mobile];
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    businessName = json[DicParams.businessName];
    role = json[DicParams.role];
    isApprovedByAdmin = json[DicParams.isApprovedByAdmin];
    profilePicture = json[DicParams.profilePicture];
  }
}
