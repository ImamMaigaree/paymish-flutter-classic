import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';
import '../../profile/wallet/model/req_wallet_setup.dart';
import '../model/res_bank_list.dart';

class AddBankDetailsScreen extends StatefulWidget {
  const AddBankDetailsScreen({Key? key}) : super(key: key);

  @override
  _AddBankDetailsScreenState createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _userNameFocus = FocusNode();
  final FocusNode _accountNumberFocus = FocusNode();
  List<BankListItem> _categoryList = <BankListItem>[];
  BankListItem? _selectedBank;
  String? _accountNumber;
  String? _userName;

  final GlobalKey<FormState> _bankAccountKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getBankList(context);
  }

  @override
  void dispose() {
    _bankNameFocus.dispose();
    _userNameFocus.dispose();
    _accountNumberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        title: Localization.of(context).labelAddBankDetails,
        isBackGround: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: spacingLarge,
                      right: spacingLarge,
                      bottom: spacingTiny,
                      top: spacingLarge),
                  child: Text(
                    Localization.of(context).labelAddBankDetailsDesc,
                    style: const TextStyle(
                      fontSize: fontMedium,
                      fontFamily: fontFamilyPoppinsRegular,
                    ),
                  ),
                ),
                Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _bankAccountKey,
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
              _getSubmitButton(),
            ],
          )
        ],
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
          onChanged: (BankListItem? newValueSelected) {
            setState(() {
              _selectedBank = newValueSelected;
            });
          },
        ));
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
        hint: Localization.of(context).labelBankAccountNumber,
        label: Localization.of(context).labelBankAccountNumber,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        maxLength: 11,
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

  void _nextPressed() {
    if (_bankAccountKey.currentState?.validate() ?? false) {
      _bankAccountKey.currentState?.save();

      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .addBankAccount(ReqWalletSetup(
              code: _selectedBank?.code ?? '',
              bankName: _selectedBank?.name ?? '',
              bankHolderName: (_userName ?? '').trim(),
              fsiAccountNumber: (_accountNumber ?? '').trim()))
          .then((value) {
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        _updatePreferences();
        NavigationUtils.pop(context);
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
