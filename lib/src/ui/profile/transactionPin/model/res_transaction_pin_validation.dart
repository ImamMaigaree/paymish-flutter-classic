import '../../../../apis/dic_params.dart';

class ResTransactionPinValidation {
  Data? data;

  ResTransactionPinValidation({this.data});

  ResTransactionPinValidation.fromJson(Map<String, dynamic> json) {
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
  int? isValid;

  Data({this.isValid});

  Data.fromJson(Map<String, dynamic> json) {
    isValid = json[DicParams.isValid];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.isValid] = isValid;
    return data;
  }
}
