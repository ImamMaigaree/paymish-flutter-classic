import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/app_config.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';
import 'model/req_transaction_pin.dart';

class TransactionPinSetupScreen extends StatefulWidget {
  final bool showBackButton;

  const TransactionPinSetupScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  _TransactionPinSetupScreenState createState() =>
      _TransactionPinSetupScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showBackButton', showBackButton));
  }
}

class _TransactionPinSetupScreenState extends State<TransactionPinSetupScreen> {
  final FocusNode _transactionPinFocus = FocusNode();
  final FocusNode _confirmTransactionPinFocus = FocusNode();

  final TextEditingController _transactionPinController =
      TextEditingController();
  final TextEditingController _confirmTransactionPinController =
      TextEditingController();

  String _transactionPin = '';

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _transactionPinFocus.dispose();
    _confirmTransactionPinFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBackButton
          ? PaymishAppBar(
              title: Localization.of(context).labelTransActionPinSetup,
              isBackGround: false,
            )
          : null,
      body: Form(
        autovalidateMode: AutovalidateMode.disabled, key: _key,
        child: Column(
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
                            Localization.of(context).labelTransActionPinSetup,
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
                    child: Image.asset(ImageConstants.icTransactionPinSetup),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: spacingLarge,
                        right: spacingLarge,
                        bottom: spacingTiny,
                        top: spacingLarge),
                    child: Text(
                      Localization.of(context)
                          .labelTransActionPinSetupDescription,
                      style: const TextStyle(
                        fontSize: fontMedium,
                        fontFamily: fontFamilyPoppinsRegular,
                      ),
                    ),
                  ),
                  _getTransactionPinTextField(),
                  _getConfirmTransactionPinTextField(),
                ],
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                widget.showBackButton ? const SizedBox() : _getSkipButton(),
                _getSubmitButton()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTransactionPinTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingMedium, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _transactionPinFocus,
        onSaved: (value) {
          _transactionPin = value ?? '';
        },
        controller: _transactionPinController,
        onFieldSubmitted: (_) {
          _transactionPinFocus.unfocus();
          FocusScope.of(context).requestFocus(_confirmTransactionPinFocus);
        },
        type: TextInputType.number,
        maxLength: 4,
        isObscureText: true,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        hint: Localization.of(context).transActionPin,
        label: Localization.of(context).transActionPin,
        validateFunction: (value) {
          return Utils.isValidPin(
            context,
            value,
            Localization.of(context).errorTransActionPin,
          );
        },
      ),
    );
  }

  Widget _getConfirmTransactionPinTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingMedium, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.done,
        focusNode: _confirmTransactionPinFocus,
        controller: _confirmTransactionPinController,
        onFieldSubmitted: (_) {
          _confirmTransactionPinFocus.unfocus();
        },
        type: TextInputType.number,
        isObscureText: true,
        hint: Localization.of(context).confirmTransActionPin,
        label: Localization.of(context).confirmTransActionPin,
        maxLength: 4,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        validateFunction: (value) {
          return Utils.isPinValueSame(
              context,
              _confirmTransactionPinController.text.trim(),
              _transactionPinController.text.trim(),
              Localization.of(context).errorPinDoesNotMatch);
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
              bottom: spacingLarge),
          child: PaymishPrimaryButton(
            buttonText: Localization.of(context).labelSubmit,
            isBackground: true,
            onButtonClick: _submitPressed,
          ),
        ),
      );

  Widget _getSkipButton() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
              top: spacingXXXXLarge,
              left: spacingLarge,
              right: spacingSmall,
              bottom: spacingLarge),
          child: PaymishPrimaryButton(
            buttonText: Localization.of(context).labelSkip,
            isBackground: false,
            onButtonClick: _skipPressed,
          ),
        ),
      );

  void _submitPressed() {
    FocusScope.of(context).unfocus();
    if (_key.currentState?.validate() ?? false) {
      _key.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .setTransactionPin(
              ReqTransactionPin(transactionPin: _transactionPin.trim()))
          .then((value) {
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        _updateSharedPref();
        if (widget.showBackButton) {
          NavigationUtils.pop(context);
        } else {
          NavigationUtils.pushAndRemoveUntil(
              context, isUserApp() ? routeMainTab : routeMerchantMainTab);
        }
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
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

  Future _updateSharedPref() async {
    await setInt(PreferenceKey.isTransactionPin, 1);
  }

  void _skipPressed() {
    //Navigate to other screen
    FocusScope.of(context).unfocus();
    if (getEnvironment() == Environment.userDev ||
        getEnvironment() == Environment.userStage ||
        getEnvironment() == Environment.userProd) {
      NavigationUtils.pushAndRemoveUntil(context, routeMainTab);
    } else {
      NavigationUtils.pushAndRemoveUntil(context, routeMerchantMainTab);
    }
  }
}
