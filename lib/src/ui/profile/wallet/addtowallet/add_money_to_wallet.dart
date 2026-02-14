import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../apis/apimanager/user_api_manager.dart';
import '../../../../apis/base_model.dart';
import '../../../../apis/dic_params.dart';
import '../../../../utils/color_utils.dart';
import '../../../../utils/common_methods.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dialog_utils.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/localization/localization.dart';
import '../../../../utils/navigation.dart';
import '../../../../utils/navigation_params.dart';
import '../../../../utils/preference_key.dart';
import '../../../../utils/preference_utils.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/header_with_amount.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../../widgets/paymish_primary_button.dart';
import '../../../../widgets/paymish_text_field.dart';

// ignore: must_be_immutable
class AddMoneyToWallet extends StatefulWidget {
  final bool isFromBottomNavigation;
  num walletAmount;

  AddMoneyToWallet(
      {Key? key, this.isFromBottomNavigation = false, this.walletAmount = 0})
      : super(key: key);

  @override
  _AddMoneyToWalletState createState() => _AddMoneyToWalletState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>(
        'isFromBottomNavigation', isFromBottomNavigation));
    properties.add(DiagnosticsProperty<num>('walletAmount', walletAmount));
  }
}

class _AddMoneyToWalletState extends State<AddMoneyToWallet> {
  final TextEditingController _amountController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final _isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.isFromBottomNavigation) {
      _walletOverviewRequest(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        title: Localization.of(context).labelAddMoneyToWallet,
        isBackGround: false,
        isFromAuth: false,
        isHideBackButton: widget.isFromBottomNavigation,
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.disabled, key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (context, isLoading, _) => isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorUtils.primaryColor),
                        ),
                      ),
                    )
                  : HeaderWithAmount(
                      titleText: Localization.of(context).labelAvailableBalance,
                      amountValue: widget.walletAmount,
                    ),
            ),
            Expanded(
              child: _amountWidget(context),
            ),
            _amountSubmitButton(context)
          ],
        ),
      ),
    );
  }

  Widget _amountSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelSubmit,
        isBackground: true,
        onButtonClick: () => _submitPressed(context),
      ),
    );
  }

  Widget _amountWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(spacingXLarge),
      child: PaymishTextField(
        controller: _amountController,
        hint: Localization.of(context).hintEnterAmount,
        label: Localization.of(context).hintEnterAmount,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(decimalAmountRegex)),
        ],
        type:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        maxLength: 6,
        validateFunction: (value) {
          return Utils.isValidMoneyAmount(context, value ?? '');
        },
      ),
    );
  }

  void _submitPressed(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      FocusScope.of(context).requestFocus(FocusNode());
      _key.currentState?.save();

      if (getString(PreferenceKey.kycStatus) == DicParams.notVerified) {
        openTransactionDetailsDialog(context, routeCompleteKYC);
      } else if (getInt(PreferenceKey.isBankAccount) == 0) {
        openTransactionDetailsDialog(context, routeWalletSetup);
      } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
        openTransactionDetailsDialog(context, routeTransactionPinSetup);
      } else {
        NavigationUtils.push(context, routeAddMoneyToWalletSelectPaymentMethod,
            arguments: {
              NavigationParams.addToWalletAmount:
                  num.parse(_amountController.text.trim()),
              NavigationParams.isWithdrawMoney: false
            });
      }
    }
  }

  void _walletOverviewRequest(BuildContext context) {
    _isLoading.value = true;
    UserApiManager().walletOverview().then((value) {
      _isLoading.value = false;
      // If API response is SUCCESS
      setState(() {
        widget.walletAmount = value.data?.walletBalance ?? 0;
      });
    }).catchError((dynamic e) {
      _isLoading.value = false;
      // If API response is FAILURE or ANY EXCEPTION
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
      // If Error occurs return amount as 0
    });
  }
}
