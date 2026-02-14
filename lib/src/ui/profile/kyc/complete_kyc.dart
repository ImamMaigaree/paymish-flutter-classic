import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
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
import 'model/req_kyc_verification.dart';

// ignore: must_be_immutable
class CompleteKYCScreen extends StatelessWidget {
  final bool showBackButton;
  final bool completeTransactionDetails;

  CompleteKYCScreen(
      {Key? key, this.showBackButton = false, this.completeTransactionDetails = false})
      : super(key: key);

  final TextEditingController _bvnNumberController = TextEditingController();

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showBackButton || completeTransactionDetails
          ? PaymishAppBar(
              title: Localization.of(context).completeKycLabel,
              isBackGround: false,
            )
          : null,
      body: Form(
        autovalidateMode: AutovalidateMode.disabled,
        key: _globalKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    showBackButton || completeTransactionDetails
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: spacingXLarge, top: spacingXXXXXLarge),
                            child: Text(
                              Localization.of(context).completeKycLabel,
                              style: const TextStyle(
                                fontSize: fontXMLarge,
                                fontFamily: fontFamilyCovesBold,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: spacingLarge,
                          right: spacingLarge,
                          bottom: spacingXXXLarge,
                          top: spacingLarge),
                      child: Text(
                        Localization.of(context).completeKycLabelDescription,
                        style: const TextStyle(
                          fontSize: fontMedium,
                          fontFamily: fontFamilyPoppinsRegular,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: spacingLarge,
                          right: spacingLarge,
                          bottom: spacingXXXXXLarge),
                      child: PaymishTextField(
                        controller: _bvnNumberController,
                        hint: Localization.of(context).bvnNumber,
                        label: Localization.of(context).bvnNumber,
                        type: TextInputType.number,
                        textInputFormatter: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 11,
                        validateFunction: (value) {
                          return Utils.isValidBVN(
                            context,
                            value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                !showBackButton || !completeTransactionDetails
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: spacingLarge,
                              right: spacingSmall,
                              bottom: spacingLarge),
                          child: PaymishPrimaryButton(
                            buttonText: Localization.of(context).labelSkip,
                            isBackground: false,
                            onButtonClick: () => _skipPressed(context),
                          ),
                        ),
                      )
                    : const SizedBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: spacingSmall,
                        right: spacingLarge,
                        bottom: spacingLarge),
                    child: PaymishPrimaryButton(
                      buttonText: Localization.of(context).verifyLabel,
                      isBackground: true,
                      onButtonClick: () {
                        if (_globalKey.currentState?.validate() ?? false) {
                          _verifyPressed(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _verifyPressed(BuildContext context) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .setKYCVerification(
            ReqKycVerification(bvnNumber: _bvnNumberController.text.trim()))
        .then((value) async {
      ProgressDialogUtils.dismissProgressDialog();
      await DialogUtils.displayToast(value.message ?? '');
      await _updateSharedPref();
      if (completeTransactionDetails) {
        if (getInt(PreferenceKey.isBankAccount) == 0) {
          NavigationUtils.pushReplacement(context, routeWalletSetup,
              arguments: {NavigationParams.showBackButton: true});
        } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
          NavigationUtils.pushReplacement(context, routeTransactionPinSetup,
              arguments: {NavigationParams.showBackButton: true});
        } else {
          NavigationUtils.pop(context);
        }
      } else if (showBackButton) {
        NavigationUtils.pop(context);
      } else {
        await NavigationUtils.pushAndRemoveUntil(context, routeWalletSetup,
            arguments: {NavigationParams.showBackButton: false});
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

  Future _updateSharedPref() async {
    await setString(PreferenceKey.kycStatus, DicParams.verified);
    await setString(PreferenceKey.bvnNumber, _bvnNumberController.text.trim());
  }

  void _skipPressed(BuildContext context) {
    if (getString(PreferenceKey.role) == DicParams.roleMerchant) {
      NavigationUtils.pushAndRemoveUntil(context, routeMerchantMainTab);
    } else {
      NavigationUtils.pushAndRemoveUntil(context, routeMainTab);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showBackButton', showBackButton));
    properties.add(DiagnosticsProperty<bool>(
        'completeTransactionDetails', completeTransactionDetails));
  }
}
