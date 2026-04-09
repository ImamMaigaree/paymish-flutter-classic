import '../../../../apis/dic_params.dart';

class ReqSignUp {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? password;
  String? role;
  String? businessName;
  String? businessCategories;
  String? businessDescription;
  String? dateOfBirth;
  String? gender;
  String? residentialAddress;

  ReqSignUp({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.role,
    this.businessName,
    this.businessCategories,
    this.businessDescription,
    this.dateOfBirth,
    this.gender,
    this.residentialAddress,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (firstName != null) data[DicParams.firstName] = firstName;
    if (lastName != null) data[DicParams.lastName] = lastName;
    if (email != null) data[DicParams.email] = email;
    if (mobile != null) data[DicParams.mobile] = mobile;
    if (password != null) data[DicParams.password] = password;
    if (role != null) data[DicParams.role] = role;
    if (businessName != null) data[DicParams.businessName] = businessName;
    if (businessCategories != null) {
      data[DicParams.businessCategories] = businessCategories;
    }
    if (businessDescription != null) {
      data[DicParams.businessDescription] = businessDescription;
    }
    if (dateOfBirth != null) data[DicParams.dateOfBirth] = dateOfBirth;
    if (gender != null) data[DicParams.gender] = gender;
    if (residentialAddress != null) {
      data[DicParams.residentialAddress] = residentialAddress;
    }
    return data;
  }
}
