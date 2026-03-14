import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ui/paymentSetting/model/res_bank_details.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/localization/localization.dart';
import '../utils/navigation.dart';
import '../utils/navigation_params.dart';

@immutable
class BankCardRadioList extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final BankDetail bankDetail;
  final num paymentAmount;
  final bool isFromTopUpWallet;
  final ValueChanged<int?>? onChanged;
  final bool isWithdrawMoney;

  const BankCardRadioList(
      {Key? key,
      this.index = 0,
      required this.selectedIndex,
      required this.bankDetail,
      this.paymentAmount = 0,
      this.isFromTopUpWallet = false,
      this.onChanged,
      this.isWithdrawMoney = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: spacingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacingTiny),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: spacingLarge,
          ),
        ],
      ),
      child: RadioGroup<int>(
        groupValue: selectedIndex,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        child: ListTile(
          leading: Radio(
            value: index,
            activeColor: ColorUtils.primaryColor,
          ),
          title: Text(
            bankDetail.accountType == "card"
                ? Localization.of(context).labelCard
                : bankDetail.bankName ?? '',
            style: const TextStyle(
              fontFamily: fontFamilyPoppinsMedium,
              color: ColorUtils.primaryTextColor,
              fontSize: fontMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            bankDetail.maskedAccountNumber ?? '',
            style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.merchantHomeRow,
              fontSize: fontSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: selectedIndex == index
              ? ActionChip(
                  padding:
                      const EdgeInsets.symmetric(horizontal: spacingXSmall),
                  label: Text(
                    isWithdrawMoney
                        ? Localization.of(context).labelProceed.toUpperCase()
                        : Localization.of(context).labelPay.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: fontFamilyCovesBold,
                      fontSize: fontSmall,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: () =>
                      payButtonClick(context, paymentAmount, bankDetail),
                  backgroundColor: ColorUtils.primaryColor,
                )
              : const SizedBox(),
          onTap: onChanged == null ? null : () => onChanged!(index),
        ),
      ),
    );
  }

  void payButtonClick(
      BuildContext context, num amount, dynamic paymentDetails) {
    // If(Wallet TopUp Payment) {Top Up Now}
    // Else {Navigate to Transaction Pin Screen}
    if (isWithdrawMoney) {
      NavigationUtils.push(context, routeReviewBankTransfer, arguments: {
        NavigationParams.paymentAmount: amount,
        NavigationParams.paymentDetails: bankDetail,
      });
    } else if (isFromTopUpWallet) {
      NavigationUtils.push(context, routeTransactionPin, arguments: {
        NavigationParams.paymentAmount: amount,
        NavigationParams.paymentDetails: paymentDetails,
        NavigationParams.isBankPayment: true,
        NavigationParams.isTransferMoney: false,
        NavigationParams.isRequestMoney: false,
        NavigationParams.isCardPayment: false,
        NavigationParams.isNetBankingPayment: false,
        NavigationParams.isDataRecharge: false,
        NavigationParams.isTvSubscription: false,
        NavigationParams.isElectricityBill: false,
      });
    } else {
      NavigationUtils.push(context, routeTransactionPin, arguments: {
        NavigationParams.paymentAmount: amount,
        NavigationParams.paymentDetails: paymentDetails,
        NavigationParams.isBankPayment: true,
      });
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(IntProperty('selectedIndex', selectedIndex));
    properties.add(DiagnosticsProperty<BankDetail>('bankDetail', bankDetail));
    properties.add(DiagnosticsProperty<num>('paymentAmount', paymentAmount));
    properties
        .add(DiagnosticsProperty<bool>('isFromTopUpWallet', isFromTopUpWallet));
    properties
        .add(DiagnosticsProperty<ValueChanged<int?>?>('onChanged', onChanged));
    properties
        .add(DiagnosticsProperty<bool>('isWithdrawMoney', isWithdrawMoney));
  }
}
