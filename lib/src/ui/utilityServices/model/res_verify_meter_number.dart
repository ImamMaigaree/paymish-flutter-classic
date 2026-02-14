import '../../../apis/dic_params.dart';

class ResVerifyMeterNumber {
  DataVerifyNumber? data;

  ResVerifyMeterNumber({this.data});

  ResVerifyMeterNumber.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? DataVerifyNumber.fromJson(json[DicParams.data])
        : null;
  }
}

class DataVerifyNumber {
  String? customerName;
  String? meterNumber;
  String? customerDistrict;
  String? address;

  DataVerifyNumber(
      {this.customerName,
      this.meterNumber,
      this.customerDistrict,
      this.address});

  DataVerifyNumber.fromJson(Map<String, dynamic> json) {
    customerName = json[DicParams.customer_Name]?.toString();
    meterNumber = json[DicParams.meter_Number]?.toString();
    customerDistrict = json[DicParams.customer_District]?.toString();
    address = json[DicParams.address]?.toString();
  }
}
