import '../../../apis/dic_params.dart';

class ResContactModel {
  String? message;
  List<ContactResponseModel>? data;

  ResContactModel({this.message, this.data});

  ResContactModel.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    if (json[DicParams.data] != null) {
      data = <ContactResponseModel>[];
      json['data'].forEach((v) {
        data?.add(ContactResponseModel.fromJson(v));
      });
    }
  }
}

class ContactResponseModel {
  int? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? profilePicture;

  ContactResponseModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.mobile,
      this.profilePicture});

  ContactResponseModel.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    mobile = json[DicParams.mobile];
    profilePicture = json[DicParams.profilePicture];
  }
}
