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
import '../../../widgets/one_trust_appbar.dart';
import '../../../widgets/one_trust_primary_button.dart';
import '../../../widgets/one_trust_text_field.dart';
import 'igree_consent_screen.dart';
import 'model/req_igree_kyc_start.dart';
import 'model/res_igree_kyc_exchange.dart';

// ignore: must_be_immutable
class CompleteKYCScreen extends StatelessWidget {
  final bool showBackButton;
  final bool completeTransactionDetails;

  CompleteKYCScreen({
    super.key,
    this.showBackButton = false,
    this.completeTransactionDetails = false,
  });

  final TextEditingController _bvnNumberController = TextEditingController();

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showBackButton || completeTransactionDetails
          ? OneTrustAppBar(
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
                              left: spacingXLarge,
                              top: spacingXXXXXLarge,
                            ),
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
                        top: spacingLarge,
                      ),
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
                        bottom: spacingLarge,
                      ),
                      child: OneTrustTextField(
                        controller: _bvnNumberController,
                        hint: Localization.of(context).bvnNumber,
                        label: Localization.of(context).bvnNumber,
                        type: TextInputType.number,
                        textInputFormatter: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 11,
                        validateFunction: (value) {
                          return Utils.isValidBVN(context, value);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: spacingLarge,
                        right: spacingLarge,
                        bottom: spacingXXXXXLarge,
                      ),
                      child: _buildKycCheckCard(),
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
                            bottom: spacingLarge,
                          ),
                          child: OneTrustPrimaryButton(
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
                      bottom: spacingLarge,
                    ),
                    child: OneTrustPrimaryButton(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycCheckCard() {
    return Container(
      padding: const EdgeInsets.all(spacingMedium),
      decoration: BoxDecoration(
        color: const Color(0xffF1F8F9),
        border: Border.all(color: const Color(0xffCAE0E5)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Column(
        children: [
          _KycCheckRow(
            icon: Icons.check_circle_rounded,
            color: Color(0xff1f7a32),
            text: 'BVN format valid',
          ),
          SizedBox(height: spacingTiny),
          _KycCheckRow(
            icon: Icons.open_in_browser_rounded,
            color: Color(0xff0f5d75),
            text: 'NIBSS iGree consent opens next',
          ),
          SizedBox(height: spacingTiny),
          _KycCheckRow(
            icon: Icons.pending_rounded,
            color: Color(0xff8b5a00),
            text: 'NIN check pending',
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPressed(BuildContext context) async {
    ProgressDialogUtils.showProgressDialog(context);
    try {
      final value = await UserApiManager().startIgreeKyc(
        ReqIgreeKycStart(
          userId: getInt(PreferenceKey.id),
          bvnNumber: _bvnNumberController.text.trim(),
        ),
      );
      ProgressDialogUtils.dismissProgressDialog();
      if (!context.mounted) {
        return;
      }

      final authorizationUrl = value.data?.authorizationUrl ?? '';
      final sessionId = value.data?.sessionId ?? '';
      if (authorizationUrl.isEmpty || sessionId.isEmpty) {
        DialogUtils.showAlertDialog(
          context,
          value.message ?? 'Unable to start BVN consent.',
        );
        return;
      }

      final consentResult = await Navigator.of(context).push<IgreeKycExchangeData>(
        MaterialPageRoute(
          builder: (_) => IgreeConsentScreen(
            authorizationUrl: authorizationUrl,
            sessionId: sessionId,
            bvnNumber: _bvnNumberController.text.trim(),
          ),
        ),
      );

      if (!context.mounted || consentResult == null) {
        return;
      }

      await DialogUtils.displayToast('BVN verified successfully.');
      await _updateSharedPref(consentResult);
      if (!context.mounted) {
        return;
      }

      if (completeTransactionDetails) {
        if (getInt(PreferenceKey.isBankAccount) == 0) {
          NavigationUtils.pushReplacement(
            context,
            routeWalletSetup,
            arguments: {NavigationParams.showBackButton: true},
          );
        } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
          NavigationUtils.pushReplacement(
            context,
            routeTransactionPinSetup,
            arguments: {NavigationParams.showBackButton: true},
          );
        } else {
          NavigationUtils.pop(context);
        }
      } else if (showBackButton) {
        NavigationUtils.pop(context);
      } else {
        final nextRoute = getString(PreferenceKey.role) == DicParams.roleMerchant
            ? routeMerchantMainTab
            : routeMainTab;
        await NavigationUtils.pushAndRemoveUntil(context, nextRoute);
      }
    } catch (e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (!context.mounted) {
        return;
      }

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
    }
  }

  Future _updateSharedPref(IgreeKycExchangeData result) async {
    await setString(
      PreferenceKey.kycStatus,
      result.kycStatus ?? DicParams.verified,
    );
    await setString(
      PreferenceKey.bvnNumber,
      result.bvnNumber ?? _bvnNumberController.text.trim(),
    );
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
    properties.add(
      DiagnosticsProperty<bool>(
        'completeTransactionDetails',
        completeTransactionDetails,
      ),
    );
  }
}

class _KycCheckRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _KycCheckRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: spacingMedium, color: color),
        const SizedBox(width: spacingTiny),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: fontSmall,
              fontFamily: fontFamilyPoppinsRegular,
            ),
          ),
        ),
      ],
    );
  }
}
