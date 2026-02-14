import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';
import '../../paymentSetting/model/res_bank_list.dart';
import 'model/req_wallet_setup.dart';

class WalletSetupScreen extends StatefulWidget {
  final bool showBackButton;

  const WalletSetupScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  _WalletSetupScreenState createState() => _WalletSetupScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showBackButton', showBackButton));
  }
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _accountNumberFocus = FocusNode();
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _cardHolderNameFocus = FocusNode();
  final FocusNode _expireMonthFocus = FocusNode();
  final FocusNode _expireYearFocus = FocusNode();
  final FocusNode _cvvNumberFocus = FocusNode();

  final FocusNode _userNameFocus = FocusNode();
  List<BankListItem> _categoryList = <BankListItem>[];
  BankListItem? _selectedBank;
  String _userName = '';

  String _bankName = '';
  String _accountNumber = '';

  final GlobalKey<FormState> _bankAccountKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getBankList(context);
  }

  @override
  void dispose() {
    _bankNameFocus.dispose();
    _accountNumberFocus.dispose();
    _cardNumberFocus.dispose();
    _cardHolderNameFocus.dispose();
    _expireMonthFocus.dispose();
    _expireYearFocus.dispose();
    _cvvNumberFocus.dispose();
    _userNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBackButton
          ? PaymishAppBar(
              title: Localization.of(context).labelWalletSetup,
              isBackGround: false,
            )
          : null,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.showBackButton
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: spacingXLarge, top: spacingXXXXXLarge),
                        child: Text(
                          Localization.of(context).labelWalletSetup,
                          style: const TextStyle(
                            fontSize: fontXMLarge,
                            fontFamily: fontFamilyPoppinsMedium,
                            fontWeight: FontWeight.w500,
                            color: ColorUtils.primaryColor,
                          ),
                          maxLines: 2,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: spacingXXXXXXLarge,
                      right: spacingXXXXXXLarge,
                      bottom: spacingTiny),
                  child: Image.asset(ImageConstants.icWalletSetup),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: spacingLarge,
                      right: spacingLarge,
                      bottom: spacingTiny,
                      top: spacingLarge),
                  child: Text(
                    Localization.of(context).labelWalletSetupUserDescription,
                    style: const TextStyle(
                      fontSize: fontMedium,
                      fontFamily: fontFamilyPoppinsRegular,
                    ),
                  ),
                ),
                Form(
                  autovalidateMode: AutovalidateMode.disabled, key: _bankAccountKey,
                  child: Column(
                    children: <Widget>[
                      _getUserNameTextField(),
                      _getAccountNumberTextField(),
                      _paymentCategoryWidget(context),
                    ],
                  ),
                )
              ],
            )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              widget.showBackButton ? const SizedBox() : _getSkipButton(),
              _getSubmitButton(),
            ],
          )
        ],
      ),
    );
  }

  Widget _getBankNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingXLarge, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _bankNameFocus,
        onSaved: (value) {
          _bankName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _bankNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_accountNumberFocus);
        },
        type: TextInputType.text,
        hint: Localization.of(context).bankName,
        label: Localization.of(context).bankName,
        validateFunction: (value) {
          return Utils.isEmpty(
            context,
            value,
            Localization.of(context).errorBankName,
          );
        },
      ),
    );
  }

  Widget _getAccountNumberTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingMedium, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _accountNumberFocus,
        onSaved: (value) {
          _accountNumber = value ?? '';
        },
        onFieldSubmitted: (_) {
          _accountNumberFocus.unfocus();
        },
        type: TextInputType.number,
        hint: Localization.of(context).accountNumber,
        label: Localization.of(context).accountNumber,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        maxLength: 30,
        validateFunction: (value) {
          return Utils.isValidAccountNumber(context, value);
        },
      ),
    );
  }

  Widget _getUserNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingMedium, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _userNameFocus,
        onSaved: (value) {
          _userName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _userNameFocus.unfocus();
        },
        type: TextInputType.text,
        hint: Localization.of(context).labelBankHolderName,
        label: Localization.of(context).labelBankHolderName,
        maxLength: 60,
        validateFunction: (value) {
          return Utils.isEmpty(context, value,
              Localization.of(context).labelEnterBankHolderName);
        },
      ),
    );
  }

  Widget _paymentCategoryWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingLarge, left: spacingLarge, right: spacingLarge),
        child: DropdownButtonFormField<BankListItem>(
          isExpanded: true,
          itemHeight: 100.0,
          style: const TextStyle(
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsRegular),
          validator: (value) =>
              value == null ? Localization.of(context).errorSelectBank : null,
          hint: Text(
            Localization.of(context).labelSelectBank,
            style: const TextStyle(color: ColorUtils.primaryColor),
          ),
          items: _categoryList.map((value) {
            return DropdownMenuItem<BankListItem>(
              value: value,
              child: Text(value.name ?? ''),
            );
          }).toList(),
          initialValue: _selectedBank,
          onChanged: (newValueSelected) {
            setState(() {
              _selectedBank = newValueSelected;
            });
          },
        ));
  }

  Widget _getSubmitButton() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
              top: spacingXXXXLarge,
              left: spacingSmall,
              right: spacingLarge,
              bottom: spacingXLarge),
          child: PaymishPrimaryButton(
            buttonText: Localization.of(context).labelSubmit,
            isBackground: true,
            onButtonClick: _nextPressed,
          ),
        ),
      );

  Widget _getSkipButton() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
              top: spacingXXXXLarge,
              left: spacingLarge,
              right: spacingSmall,
              bottom: spacingXLarge),
          child: PaymishPrimaryButton(
            buttonText: Localization.of(context).labelSkip,
            isBackground: false,
            onButtonClick: _skipPressed,
          ),
        ),
      );

  void _nextPressed() {
    if (_bankAccountKey.currentState?.validate() ?? false) {
      _bankAccountKey.currentState?.save();
      final selectedBank = _selectedBank;
      if (selectedBank == null) {
        DialogUtils.displayToast(Localization.of(context).errorSelectBank);
        return;
      }

      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .addBankAccount(ReqWalletSetup(
              code: selectedBank.code,
              bankName: selectedBank.name,
              bankHolderName: _userName.trim(),
              fsiAccountNumber: _accountNumber.trim()))
          .then((value) async {
        ProgressDialogUtils.dismissProgressDialog();
        await DialogUtils.displayToast(value.message ?? '');
        await _updatePreferences();

        if (widget.showBackButton) {
          if (getInt(PreferenceKey.isTransactionPin) == 0) {
            NavigationUtils.pushReplacement(context, routeTransactionPinSetup,
                arguments: {NavigationParams.showBackButton: true});
          } else {
            NavigationUtils.pop(context);
          }
        } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
          await NavigationUtils.pushAndRemoveUntil(
              context, routeTransactionPinSetup,
              arguments: {NavigationParams.showBackButton: false});
        } else {
          if (isUserApp()) {
            NavigationUtils.pushReplacement(context, routeMainTab);
          } else {
            NavigationUtils.pushReplacement(context, routeMerchantMainTab);
          }
        }
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            debugPrint(e.error);
            DialogUtils.showAlertDialog(context, e.error ?? '');
          } else {
            DialogUtils.showAlertDialog(context, e.message ?? '');
          }
        } else {
          DialogUtils.showAlertDialog(context, e.toString());
        }
      });
    }
  }

  Future _updatePreferences() async {
    await setInt(PreferenceKey.isBankAccount, 1);
  }

  void _skipPressed() {
    if (isUserApp()) {
      NavigationUtils.push(context, routeMainTab);
    } else {
      NavigationUtils.push(context, routeMerchantMainTab);
    }
  }

  void _getBankList(BuildContext context) {
    UserApiManager().getBankList().then((value) {
      setState(() {
        _categoryList = value.data ?? <BankListItem>[];
      });
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          debugPrint(e.error);
          DialogUtils.showAlertDialog(context, e.error ?? '');
        } else {
          DialogUtils.showAlertDialog(context, e.message ?? '');
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
  }
}
