import 'package:flutter/material.dart';

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
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';
import 'model/req_forget_password.dart';

// ignore: must_be_immutable
class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).forgotPasswordLabel,
        isBackGround: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  forgotPasswordDescriptionWidget(context),
                  forgotPasswordPhoneNumberWidget(context),
                  separatorWidget(context),
                  forgotPasswordEmailWidget(context),
                ],
              ),
            ),
          ),
          forgotPasswordProceedButtonWidget(context)
        ],
      ),
    );
  }

  Widget forgotPasswordProceedButtonWidget(BuildContext context) {
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

  Widget forgotPasswordEmailWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: spacingXLarge,
          left: spacingLarge,
          right: spacingLarge,
          bottom: spacingXXLarge),
      child: PaymishTextField(
        controller: _emailController,
        hint: Localization.of(context).emailAddress,
        label: Localization.of(context).emailAddress,
        type: TextInputType.emailAddress,
      ),
    );
  }

  Widget separatorWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 2,
          color: ColorUtils.primaryColor,
          width: spacingXLarge,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            Localization.of(context).labelOr,
            style: const TextStyle(
                color: ColorUtils.primaryColor,
                fontSize: fontXLarge,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 2,
          color: ColorUtils.primaryColor,
          width: spacingXLarge,
        ),
      ],
    );
  }

  Widget forgotPasswordPhoneNumberWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXXLarge),
      child: PaymishTextField(
        controller: _phoneNumberController,
        hint: Localization.of(context).phoneNumber,
        label: Localization.of(context).phoneNumber,
        type: TextInputType.phone,
        prefixCountryCode: countryCode,
        isPrefixCountryCode: true,
        isLeadingIcon: true,
        maxLength: 10,
        leadingIcon: ImageConstants.icNigeria,
      ),
    );
  }

  Widget forgotPasswordDescriptionWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge,
          right: spacingLarge,
          bottom: spacingXXXXLarge,
          top: spacingLarge),
      child: Text(
        Localization.of(context).forgotPasswordDescription,
        style: const TextStyle(
            fontSize: fontMedium,
            fontFamily: fontFamilyPoppinsRegular,
            height: 1.4),
      ),
    );
  }

  void _proceedPressed(BuildContext context) {
    if (_phoneNumberController.text.trim().isEmpty &&
        _emailController.text.trim().isEmpty) {
      DialogUtils.displayToast(
          Localization.of(context).errorEnterPhoneOrEmail);
    } else if (_phoneNumberController.text.isNotEmpty) {
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .forgetPassword(ReqForgetPassword(
        mobile: _phoneNumberController.text.trim(),
      ))
          .then((value) {
        debugPrint(value.message ?? '');
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        NavigationUtils.push(context, routeForgotPasswordOTP, arguments: {
          NavigationParams.phoneNumber: _phoneNumberController.text.trim(),
          NavigationParams.model: value.data
        });
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            debugPrint(e.error);
            DialogUtils.showAlertDialog(context, e.error ?? '');
          }
        }
      });
    } else if (_emailController.text.isNotEmpty) {
      if (!Utils.isEmailValid(_emailController.text)) {
        ProgressDialogUtils.showProgressDialog(context);
        UserApiManager()
            .forgetPassword(ReqForgetPassword(
          email: _emailController.text.trim(),
        ))
            .then((value) {
          debugPrint(value.message ?? '');
          ProgressDialogUtils.dismissProgressDialog();
          DialogUtils.displayToast(value.message ?? '');
          DialogUtils.showOkCancelAlertDialog(
              context: context,
              message: Localization.of(context).msgResetPasswordFromEmail,
              okButtonTitle: Localization.of(context).ok,
              okButtonAction: () => _okButtonClicked(context),
              cancelButtonTitle: '',
              cancelButtonAction: () => _okButtonClicked(context),
              isCancelEnable: false);
        }).catchError((dynamic e) {
          ProgressDialogUtils.dismissProgressDialog();
          if (e is ResBaseModel) {
            if (!checkSessionExpire(e, context)) {
              debugPrint(e.error);
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
      } else {
        DialogUtils.displayToast(Localization.of(context).errorEmailAddress);
      }
    }
  }

  void _okButtonClicked(BuildContext context) {
    NavigationUtils.pushAndRemoveUntil(context, routeLogin);
  }
}
