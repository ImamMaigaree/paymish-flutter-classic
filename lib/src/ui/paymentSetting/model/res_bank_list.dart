class ResBankList {
  List<BankListItem>? data;

  ResBankList({this.data});

  ResBankList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <BankListItem>[];
      json['data'].forEach((v) {
        data?.add(BankListItem.fromJson(v));
      });
    }
  }
}

class BankListItem {
  String? name;
  String? slug;
  String? code;
  String? longcode;
  String? gateway;
  bool? payWithBank;
  bool? active;
  bool? isDeleted;
  String? country;
  String? currency;
  String? type;
  int? id;
  String? createdAt;
  String? updatedAt;

  BankListItem(
      {this.name,
      this.slug,
      this.code,
      this.longcode,
      this.gateway,
      this.payWithBank,
      this.active,
      this.isDeleted,
      this.country,
      this.currency,
      this.type,
      this.id,
      this.createdAt,
      this.updatedAt});

  BankListItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    code = json['code'];
    longcode = json['longcode'];
    gateway = json['gateway'];
    payWithBank = json['pay_with_bank'];
    active = json['active'];
    isDeleted = json['is_deleted'];
    country = json['country'];
    currency = json['currency'];
    type = json['type'];
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
