import '../../../../apis/dic_params.dart';

class ReqEditProfile {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? businessDescription;
  String? businessName;

  ReqEditProfile(
      {this.firstName,
      this.lastName,
      this.email,
      this.mobile,
      this.businessDescription,
      this.businessName});

  ReqEditProfile.fromJson(Map<String, dynamic> json) {
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    email = json[DicParams.email];
    mobile = json[DicParams.mobile];
    businessDescription = json[DicParams.businessDescription];
    businessName = json[DicParams.businessName];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.firstName] = firstName;
    data[DicParams.lastName] = lastName;
    data[DicParams.email] = email;
    data[DicParams.mobile] = mobile;
    data[DicParams.businessDescription] = businessDescription;
    data[DicParams.businessName] = businessName;
    return data;
  }
}
