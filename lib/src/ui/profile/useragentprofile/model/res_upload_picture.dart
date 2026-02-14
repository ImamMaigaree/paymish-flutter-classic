import '../../../../apis/dic_params.dart';

class ResUploadProfilePicture {
  String? message;
  UploadProfilePicture? data;

  ResUploadProfilePicture({this.message, this.data});

  ResUploadProfilePicture.fromJson(Map<String, dynamic> json) {
    message = json[DicParams.message];
    data = json[DicParams.data] != null
        ? UploadProfilePicture.fromJson(json[DicParams.data])
        : null;
  }
}

class UploadProfilePicture {
  String? profilePicture;
  String? thumbnail;

  UploadProfilePicture({this.profilePicture, this.thumbnail});

  UploadProfilePicture.fromJson(Map<String, dynamic> json) {
    profilePicture = json[DicParams.profilePicture];
    thumbnail = json[DicParams.thumbnail];
  }
}
