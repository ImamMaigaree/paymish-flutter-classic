import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../apis/apimanager/user_api_manager.dart';
import '../../../../apis/base_model.dart';
import '../../../../utils/color_utils.dart';
import '../../../../utils/common_methods.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dialog_utils.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/localization/localization.dart';
import '../../../../utils/navigation.dart';
import '../../../../utils/navigation_params.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/header_with_amount.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../../widgets/paymish_primary_button.dart';
import '../../../../widgets/paymish_text_field.dart';
import 'model/req_checkout_withdraw_amount.dart';
import 'provider/withdraw_money_provider.dart';

// ignore: must_be_immutable
class WithDrawMoneyScreen extends StatefulWidget {
  final num walletAmount;

  const WithDrawMoneyScreen({Key? key, this.walletAmount = 0})
      : super(key: key);

  @override
  _WithDrawMoneyScreenState createState() => _WithDrawMoneyScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<num>('walletAmount', walletAmount));
  }
}

class _WithDrawMoneyScreenState extends State<WithDrawMoneyScreen> {
  final TextEditingController _withdrawAmountController =
      TextEditingController();

  num _payAbleAmount = 0;
  num _charges = 0;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        title: Localization.of(context).labelWithDrawMoneyToWallet,
        isBackGround: false,
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.disabled, key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithAmount(
              titleText: Localization.of(context).labelAvailableBalance,
              amountValue: widget.walletAmount,
            ),
            labelSendToBankWidget(context),
            Expanded(
              child: amountChargesAndPayableWidget(context),
            ),
            amountProceedButton(context)
          ],
        ),
      ),
    );
  }

  Widget labelSendToBankWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge,
          right: spacingLarge,
          top: spacingLarge,
          bottom: spacingLarge),
      child: Text(
        Localization.of(context).labelEnterAmountSendToBank,
        style: const TextStyle(
          fontSize: fontMedium,
          fontFamily: fontFamilyPoppinsRegular,
          color: ColorUtils.primaryTextColor,
        ),
      ),
    );
  }

  Widget amountProceedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelProceed,
        isBackground: true,
        onButtonClick: () => _proceedPressed(context),
      ),
    );
  }

  Widget amountChargesAndPayableWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: spacingXLarge, right: spacingXLarge),
      child: Column(
        children: [
          PaymishTextField(
            controller: _withdrawAmountController,
            hint: Localization.of(context).hintEnterAmount,
            label: Localization.of(context).hintEnterAmount,
            type: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
            textInputFormatter: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(decimalAmountRegex)),
            ],
            onChanged: (value) async {
              if (value.isEmpty) {
                setState(() {
                  _payAbleAmount = 0;
                  _charges = 0;
                });
                return;
              }
              if (num.parse(value) >= 20) {
                await _checkoutWithdrawMoneyAmount(
                    context: context, value: num.parse(value));
              } else {
                setState(() {
                  _payAbleAmount = 0;
                  _charges = 0;
                });
              }
            },
            maxLength: 8,
            validateFunction: (value) {
              return Utils.isValidAndBoundedAmount(
                  context, value ?? '', widget.walletAmount.toString());
            },
          ),
          chargesAndPayableWidget(context)
        ],
      ),
    );
  }

  Widget chargesAndPayableWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [chargesWidget(context), payableWidget(context)],
    );
  }

  Widget chargesWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          Localization.of(context).labelCharges,
          style: const TextStyle(
            fontSize: fontSmall,
            fontFamily: fontFamilyPoppinsRegular,
            color: ColorUtils.recentTextColor,
          ),
        ),
        Text(
          "₦ ${Utils.currencyFormat.format(_charges)}",
          style: const TextStyle(
            fontSize: fontSmall,
            fontFamily: fontFamilyRobotoLight,
            color: ColorUtils.recentTextColor,
          ),
        ),
      ],
    );
  }

  Widget payableWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          Localization.of(context).labelNetPayable,
          style: const TextStyle(
            fontSize: fontSmall,
            fontFamily: fontFamilyPoppinsRegular,
            color: ColorUtils.recentTextColor,
          ),
        ),
        Text(
          "₦ ${Utils.currencyFormat.format(_payAbleAmount)}",
          style: const TextStyle(
            fontSize: fontSmall,
            fontFamily: fontFamilyRobotoLight,
            color: ColorUtils.recentTextColor,
          ),
        ),
      ],
    );
  }

  void _proceedPressed(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      _key.currentState?.save();
      NavigationUtils.push(context, routeAddMoneyToWalletSelectPaymentMethod,
          arguments: {
            NavigationParams.addToWalletAmount:
                num.parse(_withdrawAmountController.text.trim()),
            NavigationParams.isWithdrawMoney: true
          });
    }
  }

  Future<void> _checkoutWithdrawMoneyAmount(
      {required BuildContext context, required num value}) async {
    await UserApiManager()
        .checkoutWithdrawMoney(ReqCheckoutWithdrawMoney(amount: value))
        .then((value) {
      // If API response is SUCCESS
      Provider.of<WithdrawMoneyProvider>(context, listen: false)
          .setAmountData(value);
      setState(() {
        _payAbleAmount = value.data?.amount ?? 0;
        _charges =
            (value.data?.withdrawalCharges ?? 0) +
                (value.data?.withdrawalVatAmount ?? 0);
      });
        }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        } else {
          DialogUtils.showAlertDialog(context, e.message ?? '');
          DialogUtils.displayToast(e.error ?? '');
          NavigationUtils.pop(context);
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
  }
}
