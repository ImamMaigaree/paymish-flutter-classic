import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';

class ResSearchModel extends ResBaseModel {
  List<SearchData>? data;

  ResSearchModel({this.data});

  ResSearchModel.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.data] != null) {
      data = <SearchData>[];
      json[DicParams.data].forEach((v) {
        data?.add(SearchData.fromJson(v));
      });
    }
  }
}

class SearchData {
  int? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? email;
  String? businessName;
  String? profilePicture;
  String? role;

  SearchData(
      {this.id,
      this.firstName,
      this.lastName,
      this.mobile,
      this.email,
      this.businessName,
      this.role,
      this.profilePicture});

  SearchData.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    mobile = json[DicParams.mobile];
    email = json[DicParams.email];
    businessName = json[DicParams.businessName];
    role = json[DicParams.role];
    profilePicture = json[DicParams.profilePicture];
  }
}
