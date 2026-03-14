import '../../../../apis/dic_params.dart';

class ResWalletOverview {
  Data? data;

  ResWalletOverview({this.data});

  ResWalletOverview.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      data[DicParams.data] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? firstName;
  String? lastName;
  String? qrCode;
  num? walletBalance;
  VirtualAccount? virtualAccount;
  VirtualAccountEligibility? virtualAccountEligibility;
  num? isApprovedByAdmin;

  Data({
    this.firstName,
    this.lastName,
    this.qrCode,
    this.walletBalance,
    this.virtualAccount,
    this.virtualAccountEligibility,
    this.isApprovedByAdmin,
  });

  Data.fromJson(Map<String, dynamic> json) {
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    qrCode = json[DicParams.qrCode];
    walletBalance = json[DicParams.walletBalance];
    isApprovedByAdmin = json['isApprovedByAdmin'];
    virtualAccount = json['virtualAccount'] != null
        ? VirtualAccount.fromJson(json['virtualAccount'])
        : null;
    virtualAccountEligibility = json['virtualAccountEligibility'] != null
        ? VirtualAccountEligibility.fromJson(json['virtualAccountEligibility'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.firstName] = firstName;
    data[DicParams.lastName] = lastName;
    data[DicParams.qrCode] = qrCode;
    data[DicParams.walletBalance] = walletBalance;
    data['isApprovedByAdmin'] = isApprovedByAdmin;
    if (virtualAccount != null) {
      data['virtualAccount'] = virtualAccount!.toJson();
    }
    if (virtualAccountEligibility != null) {
      data['virtualAccountEligibility'] = virtualAccountEligibility!.toJson();
    }
    return data;
  }
}

class VirtualAccount {
  String? virtualAccountNumber;
  String? virtualAccountName;
  String? bankName;
  String? status;

  VirtualAccount({
    this.virtualAccountNumber,
    this.virtualAccountName,
    this.bankName,
    this.status,
  });

  VirtualAccount.fromJson(Map<String, dynamic> json) {
    virtualAccountNumber = json['virtualAccountNumber']?.toString();
    virtualAccountName = json['virtualAccountName']?.toString();
    bankName = json['bankName']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'virtualAccountNumber': virtualAccountNumber,
      'virtualAccountName': virtualAccountName,
      'bankName': bankName,
      'status': status,
    };
  }
}

class VirtualAccountEligibility {
  bool? eligible;
  bool? kycVerified;
  bool? hasBvnAndNin;
  bool? adminApproved;
  bool? isBlocked;
  bool? squadEnabled;

  VirtualAccountEligibility({
    this.eligible,
    this.kycVerified,
    this.hasBvnAndNin,
    this.adminApproved,
    this.isBlocked,
    this.squadEnabled,
  });

  VirtualAccountEligibility.fromJson(Map<String, dynamic> json) {
    eligible = json['eligible'] == true;
    kycVerified = json['kycVerified'] == true;
    hasBvnAndNin = json['hasBvnAndNin'] == true;
    adminApproved = json['adminApproved'] == true;
    isBlocked = json['isBlocked'] == true;
    squadEnabled = json['squadEnabled'] == true;
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'kycVerified': kycVerified,
      'hasBvnAndNin': hasBvnAndNin,
      'adminApproved': adminApproved,
      'isBlocked': isBlocked,
      'squadEnabled': squadEnabled,
    };
  }
}
