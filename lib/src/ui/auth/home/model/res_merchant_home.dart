import '../../../../apis/dic_params.dart';

class ResMerchantHomeScreen {
  Data? data;

  ResMerchantHomeScreen({this.data});

  ResMerchantHomeScreen.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? Data.fromJson(json[DicParams.data])
        : null;
  }
}

class Data {
  num? totalPaymentReceiver;
  num? totalCommissonPaid;
  num? totalRevenueGenerated;
  int? unreadCount;
  int? totalTransactions;
  int? isApprovedByAdmin;

  Data(
      {this.totalPaymentReceiver,
      this.totalCommissonPaid,
      this.totalRevenueGenerated,
      this.unreadCount,
      this.isApprovedByAdmin,
      this.totalTransactions});

  Data.fromJson(Map<String, dynamic> json) {
    totalPaymentReceiver = json[DicParams.totalPaymentReceiver];
    totalCommissonPaid = json[DicParams.totalCommissonPaid];
    totalRevenueGenerated = json[DicParams.totalRevenueGenerated];
    unreadCount = json[DicParams.unreadCount];
    totalTransactions = json[DicParams.totalTransactions];
    isApprovedByAdmin = json[DicParams.isApprovedByAdmin];
  }
}
