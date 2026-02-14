import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';
import '../forgot_password/model/res_forget_password.dart';
import 'model/req_reset_password.dart';

// ignore: must_be_immutable
class ConfirmPasswordScreen extends StatelessWidget {
  final String phoneNumber;
  final ResForgotPasswordData model;

  ConfirmPasswordScreen(
      {Key? key, required this.phoneNumber, required this.model})
      : super(key: key);
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<bool> _willPopCallback(BuildContext context) async {
    await NavigationUtils.pushAndRemoveUntil(context, routeLogin);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _willPopCallback(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PaymishAppBar(
          title: Localization.of(context).newPasswordLabel,
          isBackGround: false,
          isFromAuth: false,
        ),
        body: Form(
          autovalidateMode: AutovalidateMode.disabled,
          key: _key,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      newPasswordFieldWidget(context),
                      confirmPasswordFieldWidget(context),
                    ],
                  ),
                ),
              ),
              passwordResetSubmitButtonWIdget(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget passwordResetSubmitButtonWIdget(BuildContext context) {
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

  Widget confirmPasswordFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: spacingXLarge, right: spacingXLarge),
      child: PaymishTextField(
        controller: _confirmPasswordController,
        hint: Localization.of(context).confirmPasswordLabel,
        label: Localization.of(context).confirmPasswordLabel,
        type: TextInputType.text,
        focusNode: _confirmPasswordFocusNode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          _confirmPasswordFocusNode.unfocus();
        },
        isObscureText: true,
        isPassword: true,
        validateFunction: (value) {
          return Utils.isPasswordMatched(
              context,
              _newPasswordController.text.trim(),
              _confirmPasswordController.text.trim());
        },
      ),
    );
  }

  Widget newPasswordFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(spacingXLarge),
      child: PaymishTextField(
        controller: _newPasswordController,
        hint: Localization.of(context).newPasswordLabel,
        label: Localization.of(context).newPasswordLabel,
        type: TextInputType.text,
        focusNode: _newPasswordFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _newPasswordFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        },
        isObscureText: true,
        isPassword: true,
        validateFunction: (value) {
          return Utils.isValidPassword(context, value);
        },
      ),
    );
  }

  // Reset password when forgot password
  void _submitPressed(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .resetPassword(ReqResetPassword(
              userId: model.userId,
              password: _newPasswordController.text.trim()))
          .then((value) async {
        // If API response is SUCCESS
        ProgressDialogUtils.dismissProgressDialog();
        await DialogUtils.displayToast(value.message ?? '');
        await clearAfterEditProfile();
        await NavigationUtils.pushAndRemoveUntil(context, routeLogin);
      }).catchError((dynamic e) {
        // If API response is FAILURE or ANY EXCEPTION
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      });
    }
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('phoneNumber', phoneNumber));
    properties.add(DiagnosticsProperty<ResForgotPasswordData>('model', model));
  }
}
