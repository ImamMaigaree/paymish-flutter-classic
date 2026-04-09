import 'package:flutter/material.dart';

import '../../../../apis/apimanager/user_api_manager.dart';
import '../../../../apis/base_model.dart';
import '../../../../utils/common_methods.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dialog_utils.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/keychain_utils.dart';
import '../../../../utils/localization/localization.dart';
import '../../../../utils/navigation.dart';
import '../../../../utils/preference_key.dart';
import '../../../../utils/preference_utils.dart';
import '../../../../utils/progress_dialog.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../../widgets/paymish_primary_button.dart';
import '../../../../widgets/paymish_text_field.dart';
import 'model/req_change_password.dart';

// ignore: must_be_immutable
class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({Key? key}) : super(key: key);

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final FocusNode _oldPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmNewPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).changePasswordLabel,
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
                    oldPasswordFieldWidget(context),
                    newPasswordFieldWidget(context),
                    confirmNewPasswordFieldWidget(context),
                  ],
                ),
              ),
            ),
            passwordSaveWidget(context)
          ],
        ),
      ),
    );
  }

  Widget passwordSaveWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelSave,
        isBackground: true,
        onButtonClick: () => _savePressed(context),
      ),
    );
  }

  Widget confirmNewPasswordFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: spacingXLarge, right: spacingXLarge),
      child: PaymishTextField(
        controller: _confirmNewPasswordController,
        hint: Localization.of(context).confirmNewPasswordLabel,
        label: Localization.of(context).confirmNewPasswordLabel,
        type: TextInputType.text,
        focusNode: _confirmNewPasswordFocusNode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          _confirmNewPasswordFocusNode.unfocus();
        },
        isObscureText: true,
        isPassword: true,
        validateFunction: (value) {
          return Utils.isPasswordMatched(
              context,
              _newPasswordController.text.trim(),
              _confirmNewPasswordController.text.trim());
        },
      ),
    );
  }

  Widget oldPasswordFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingXLarge, right: spacingXLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _oldPasswordController,
        hint: Localization.of(context).oldPasswordLabel,
        label: Localization.of(context).oldPasswordLabel,
        type: TextInputType.text,
        focusNode: _oldPasswordFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _oldPasswordFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_newPasswordFocusNode);
        },
        isObscureText: true,
        isPassword: true,
        validateFunction: (value) {
          return Utils.isValidPassword(context, value);
        },
      ),
    );
  }

  Widget newPasswordFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingXLarge, right: spacingXLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _newPasswordController,
        hint: Localization.of(context).newPasswordLabel,
        label: Localization.of(context).newPasswordLabel,
        type: TextInputType.text,
        focusNode: _newPasswordFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _newPasswordFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_confirmNewPasswordFocusNode);
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
  void _savePressed(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState?.save();
      // To close keyboard
      FocusScope.of(context).requestFocus(FocusNode());
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .changePassword(ReqChangePassword(
              currentPassword: _oldPasswordController.text.trim(),
              newPassword: _newPasswordController.text.trim()))
          .then((value) {
        // If API response is SUCCESS
        // Update password in preference
        if (getBool(PreferenceKey.isFingerPrintEnabled) == true) {
          _logoutAndUpdatePassword(
              updatedPassword: _newPasswordController.text.trim());
        }
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        // Logout and navigate to introduction screen
        NavigationUtils.pushAndRemoveUntil(context, routeIntroduction);
      }).catchError((dynamic e) {
        // If API response is FAILURE or ANY EXCEPTION
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      });
    }
  }

  // To logout person & update new password in preference for fingerprint login
  Future _logoutAndUpdatePassword({required String updatedPassword}) async {
    await logoutAndClearPreference();
    await writeKeyChainValue(
        key: PreferenceKey.password, value: updatedPassword);
  }
}
