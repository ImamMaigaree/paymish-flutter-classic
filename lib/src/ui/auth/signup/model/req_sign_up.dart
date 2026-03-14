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

  ReqSignUp(
      {this.firstName,
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
      this.residentialAddress});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.firstName] = firstName;
    data[DicParams.lastName] = lastName;
    data[DicParams.email] = email;
    data[DicParams.mobile] = mobile;
    data[DicParams.password] = password;
    data[DicParams.role] = role;
    data[DicParams.businessName] = businessName;
    data[DicParams.businessCategories] = businessCategories;
    data[DicParams.businessDescription] = businessDescription;
    data[DicParams.dateOfBirth] = dateOfBirth;
    data[DicParams.gender] = gender;
    data[DicParams.residentialAddress] = residentialAddress;
    return data;
  }
}
