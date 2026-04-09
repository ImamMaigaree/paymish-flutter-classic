import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../apis/apimanager/user_api_manager.dart';
import '../../../../apis/base_model.dart';
import '../../../../utils/dialog_utils.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/localization/localization.dart';
import '../../../../utils/navigation.dart';
import '../../../../utils/progress_dialog.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../../widgets/paymish_primary_button.dart';
import '../../../../widgets/paymish_text_field.dart';
import 'model/req_change_pin.dart';

// ignore: must_be_immutable
class ChangePinScreen extends StatelessWidget {
  ChangePinScreen({Key? key}) : super(key: key);
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmNewPinController =
      TextEditingController();
  final FocusNode _oldPinFocusNode = FocusNode();
  final FocusNode _newPinFocusNode = FocusNode();
  final FocusNode _confirmNewPinFocusNode = FocusNode();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).lblChangePin,
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
                    oldPinFieldWidget(context),
                    newPinFieldWidget(context),
                    confirmNewPinFieldWidget(context),
                  ],
                ),
              ),
            ),
            pinSaveWidget(context)
          ],
        ),
      ),
    );
  }

  Widget pinSaveWidget(BuildContext context) {
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

  Widget confirmNewPinFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: spacingXLarge, right: spacingXLarge),
      child: PaymishTextField(
        controller: _confirmNewPinController,
        hint: Localization.of(context).lblConfirmNewPin,
        label: Localization.of(context).lblConfirmNewPin,
        type: TextInputType.number,
        focusNode: _confirmNewPinFocusNode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          _confirmNewPinFocusNode.unfocus();
        },
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        maxLength: 4,
        isObscureText: true,
        validateFunction: (value) {
          return Utils.isPinValueSame(
            context,
            _newPinController.text.trim(),
            _confirmNewPinController.text.trim(),
            Localization.of(context).errorPinAndConfirmNewPinNotMatch,
          );
        },
      ),
    );
  }

  Widget oldPinFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingXLarge, right: spacingXLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _oldPinController,
        hint: Localization.of(context).lblOldPin,
        label: Localization.of(context).lblOldPin,
        type: TextInputType.number,
        focusNode: _oldPinFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _oldPinFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_newPinFocusNode);
        },
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        maxLength: 4,
        isObscureText: true,
        validateFunction: (value) {
          return Utils.isValidPin(
            context,
            value,
            Localization.of(context).errorOldTransActionPin,
          );
        },
      ),
    );
  }

  Widget newPinFieldWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingXLarge, right: spacingXLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _newPinController,
        hint: Localization.of(context).lblNewPin,
        label: Localization.of(context).lblNewPin,
        type: TextInputType.number,
        focusNode: _newPinFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _newPinFocusNode.unfocus();
          FocusScope.of(context).requestFocus(_confirmNewPinFocusNode);
        },
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        maxLength: 4,
        isObscureText: true,
        validateFunction: (value) {
          return Utils.isValidPin(
            context,
            value,
            Localization.of(context).errorNewTransActionPin,
          );
        },
      ),
    );
  }

  // Reset password when forgot password
  void _savePressed(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      // To close keyboard
      FocusScope.of(context).requestFocus(FocusNode());
      _key.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .changeTransactionPin(ReqChangePin(
        transactionPin: _oldPinController.text.trim(),
        newTransactionPin: _newPinController.text.trim(),
      ))
          .then((value) {
        // If API response is SUCCESS
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        // Navigate back to account settings screen
        NavigationUtils.pop(context);
      }).catchError((dynamic e) {
        // If API response is FAILURE or ANY EXCEPTION
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      });
    }
  }
}
