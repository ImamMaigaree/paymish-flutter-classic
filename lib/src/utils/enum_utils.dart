enum UserType { user, agent, merchant }

extension UserTypeExtentions on UserType {
  String getName() {
    switch (this) {
      case UserType.user:
        return 'user';
      case UserType.agent:
        return 'agent';
      case UserType.merchant:
        return 'merchant';
      default:
        throw RangeError("enum UserType contains no value '$this'");
    }
  }
}

enum BusinessCategories { corporate, individual }

extension BusinessCategoriesExtentions on BusinessCategories {
  String getName() {
    switch (this) {
      case BusinessCategories.corporate:
        return 'Corporate';
      case BusinessCategories.individual:
        return 'Individual';
      default:
        throw RangeError("enum BusinessCategories contains no value '$this'");
    }
  }
}

enum DocumentExt { pdf, img }

extension DocumentExtExtentions on DocumentExt {
  String getName() {
    switch (this) {
      case DocumentExt.pdf:
        return 'pdf';
      case DocumentExt.img:
        return 'img';
      default:
        throw RangeError("enum DocumentExt contains no value '$this'");
    }
  }
}

enum PaymentType { bank, card, wallet, netBanking }

extension PaymentTypeExtentions on PaymentType {
  String getPaymentType() {
    switch (this) {
      case PaymentType.bank:
        return "bank";
      case PaymentType.card:
        return "card";
      case PaymentType.wallet:
        return "wallet";
      case PaymentType.netBanking:
        return "netBanking";
      default:
        throw RangeError("enum PaymentType contains no value '$this'");
    }
  }
}

enum PaymentStatus { pending, success, failed }

extension PaymentStatusExtentions on PaymentStatus {
  String getPaymentStatus() {
    switch (this) {
      case PaymentStatus.pending:
        return "pending";
      case PaymentStatus.success:
        return "success";
      case PaymentStatus.failed:
        return "failed";
      default:
        throw RangeError("enum PaymentStatus contains no value '$this'");
    }
  }
}

enum PaymentChannel {
  channel1,
  channel2,
  channel3,
  channel4,
  channel5,
  channel6,
  channel7,
  channel8,
  channel9,
  channel10,
  channel11,
  channel12,
}

extension PaymentChannelExtentions on PaymentChannel {
  String getPaymentChannel() {
    switch (this) {
      case PaymentChannel.channel1:
        return "bank-to-bank";
      case PaymentChannel.channel2:
        return "bank-to-wallet";
      case PaymentChannel.channel3:
        return "bank-to-card";
      case PaymentChannel.channel4:
        return "wallet-to-bank";
      case PaymentChannel.channel5:
        return "wallet-to-wallet";
      case PaymentChannel.channel6:
        return "wallet-to-card";
      case PaymentChannel.channel7:
        return "card-to-bank";
      case PaymentChannel.channel8:
        return "card-to-wallet";
      case PaymentChannel.channel9:
        return "card-to-card";
      case PaymentChannel.channel10:
        return "card";
      case PaymentChannel.channel11:
        return "bank";
      case PaymentChannel.channel12:
        return "wallet";
      default:
        throw RangeError("enum PaymentChannel contains no value '$this'");
    }
  }
}

enum SupportCategory { category1, category2, category3 }

extension SupportCategoryExtentions on SupportCategory {
  String getSupportCategory() {
    switch (this) {
      case SupportCategory.category1:
        return "Support 1";
      case SupportCategory.category2:
        return "Support 2";
      case SupportCategory.category3:
        return "Support 3";
      default:
        throw RangeError("enum PaymentChannel contains no value '$this'");
    }
  }
}

enum UtilityPaymentCommission {
  airtimeRecharge,
  dataServices,
  tvSubscription,
  electricityBill
}

extension UtilityPaymentCommissionExtentions on UtilityPaymentCommission {
  String getPaymentChannel() {
    switch (this) {
      case UtilityPaymentCommission.airtimeRecharge:
        return "Airtime Recharge";
      case UtilityPaymentCommission.dataServices:
        return "Data Services";
      case UtilityPaymentCommission.tvSubscription:
        return "TV Subscription";
      case UtilityPaymentCommission.electricityBill:
        return "Electricity Bill";
      default:
        throw RangeError("enum PaymentChannel contains no value '$this'");
    }
  }
}

enum UtilityRecharge { recharge, dataRecharge }

extension UtilityRechargeExtentions on UtilityRecharge {
  String getType() {
    switch (this) {
      case UtilityRecharge.recharge:
        return "recharge";
      case UtilityRecharge.dataRecharge:
        return "data-recharge";

      default:
        throw RangeError("enum PaymentChannel contains no value '$this'");
    }
  }
}

enum UtilityRechargeIdentifier { data, airtime }

extension UtilityRechargeIdentifierExtentions on UtilityRechargeIdentifier {
  String getType() {
    switch (this) {
      case UtilityRechargeIdentifier.data:
        return "data";
      case UtilityRechargeIdentifier.airtime:
        return "airtime";

      default:
        throw RangeError("enum PaymentChannel contains no value '$this'");
    }
  }
}
