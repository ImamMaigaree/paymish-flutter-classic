import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../utils/color_utils.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/localization/localization.dart';
import '../../../../widgets/header_with_amount.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../paymentMethodSelection/payment_method_selection.dart';

// ignore: must_be_immutable
class AddMoneyToWalletSelectPaymentMethodScreen extends StatelessWidget {
  final num addToWalletAmount;
  final bool isWithdrawMoney;

  const AddMoneyToWalletSelectPaymentMethodScreen(
      {Key? key, this.addToWalletAmount = 0, this.isWithdrawMoney = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        title: isWithdrawMoney
            ? Localization.of(context).labelWithdrawMoneyToBank
            : Localization.of(context).labelAddMoneyToWallet,
        isBackGround: false,
        isFromAuth: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount To add in wallet
          HeaderWithAmount(
            titleText: isWithdrawMoney
                ? Localization.of(context).labelWithdrawMoneyToBank
                : Localization.of(context).labelAddMoneyToWallet,
            amountValue: addToWalletAmount,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: spacingLarge,
                right: spacingLarge,
                top: spacingXXXLarge,
                bottom: spacingSmall),
            child: Text(
              isWithdrawMoney
                  ? Localization.of(context).labelSelectBank
                  : Localization.of(context).labelSelectPaymentMethod,
              style: const TextStyle(
                fontFamily: fontFamilyPoppinsMedium,
                color: ColorUtils.recentTextColor,
                fontSize: fontLarge,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: PaymentMethodSelection(
              addToWalletAmount: addToWalletAmount,
              isFromTopUpWallet: true,
              isWithdrawMoney: isWithdrawMoney,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<num>('addToWalletAmount', addToWalletAmount));
    properties
        .add(DiagnosticsProperty<bool>('isWithdrawMoney', isWithdrawMoney));
  }
}
