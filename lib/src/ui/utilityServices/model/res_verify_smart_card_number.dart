import '../../../apis/dic_params.dart';

class ResVerifySmartCardNumber {
  Data? data;

  ResVerifySmartCardNumber({this.data});

  ResVerifySmartCardNumber.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }
}

class Data {
  String? customerName;
  String? status;
  String? customerID;
  String? dUEDATE;

  Data({this.customerName, this.status, this.customerID, this.dUEDATE});

  Data.fromJson(Map<String, dynamic> json) {
    customerName = json[DicParams.customer_Name]?.toString();
    status = json[DicParams.status]?.toString();
    customerID = json[DicParams.customer_ID]?.toString();
    dUEDATE = json[DicParams.DUE_DATE]?.toString();
  }
}
