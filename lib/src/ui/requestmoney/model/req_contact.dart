import '../../../apis/dic_params.dart';

class ReqContactModel {
  List<AllContacts>? allContacts;

  ReqContactModel({this.allContacts});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.allContacts] =
        (allContacts ?? <AllContacts>[]).map((v) => v.toJson()).toList();
    return data;
  }
}

class AllContacts {
  String? contactNo;

  AllContacts({this.contactNo});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.contactNo] = contactNo;
    return data;
  }
}
