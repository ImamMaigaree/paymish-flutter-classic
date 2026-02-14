import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
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
import 'model/req_edit_profile.dart';

// ignore: must_be_immutable
class EditProfileDetailsScreen extends StatelessWidget {
  EditProfileDetailsScreen({Key? key}) : super(key: key);

  final TextEditingController _firstNameController =
      TextEditingController(text: getString(PreferenceKey.firstName));
  final TextEditingController _lastNameController =
      TextEditingController(text: getString(PreferenceKey.lastName));
  final TextEditingController _emailIdController =
      TextEditingController(text: getString(PreferenceKey.email));
  final TextEditingController _phoneNumberController =
      TextEditingController(text: getString(PreferenceKey.mobile));
  final TextEditingController _businessNameController =
      TextEditingController(text: getString(PreferenceKey.businessName));
  final TextEditingController _descriptionController =
      TextEditingController(text: getString(PreferenceKey.businessDescription));
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailIdFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _businessNameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).editDetailsLabel,
        isBackGround: false,
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
                    getString(PreferenceKey.role) == DicParams.roleUser
                        ? const SizedBox()
                        : businessNameWidget(context),
                    firstNameWidget(context),
                    lastNameWidget(context),
                    emailIdWidget(context),
                    phoneNumberWidget(context),
                    // When the role is agent or merchant,
                    // Below field is required.
                    getString(PreferenceKey.role) == DicParams.roleUser
                        ? const SizedBox()
                        : businessDescriptionWidget(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: spacingLarge,
                  right: spacingLarge,
                  bottom: spacingLarge),
              child: PaymishPrimaryButton(
                buttonText: Localization.of(context).labelSave,
                isBackground: true,
                onButtonClick: () => _savePressed(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget businessDescriptionWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _descriptionController,
        hint: Localization.of(context).descriptionAboutBusiness,
        label: Localization.of(context).descriptionAboutBusiness,
        type: TextInputType.text,
        focusNode: _descriptionFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        validateFunction: (value) {
          return Utils.isEmpty(
              context, value, Localization.of(context).errorDescOfBusiness);
        },
      ),
    );
  }

  Widget businessNameWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _businessNameController,
        hint: Localization.of(context).businessName,
        label: Localization.of(context).businessName,
        type: TextInputType.text,
        focusNode: _businessNameFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _businessNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_firstNameFocus);
        },
        validateFunction: (value) {
          return Utils.isEmpty(
              context, value, Localization.of(context).errorBusinessName);
        },
      ),
    );
  }

  Widget phoneNumberWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        maxLength: 10,
        isPrefixCountryCode: true,
        isLeadingIcon: true,
        leadingIcon: ImageConstants.icNigeria,
        prefixCountryCode: countryCode,
        controller: _phoneNumberController,
        hint: Localization.of(context).phoneNumber,
        label: Localization.of(context).phoneNumber,
        type: TextInputType.phone,
        focusNode: _phoneNumberFocus,
        textInputAction: getString(PreferenceKey.role) == DicParams.roleUser
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (getString(PreferenceKey.role) == DicParams.roleUser) {
            FocusScope.of(context).requestFocus(FocusNode());
          } else {
            _phoneNumberFocus.unfocus();
            FocusScope.of(context).requestFocus(_descriptionFocus);
          }
        },
        validateFunction: (value) {
          return Utils.isMobileNumberValid(context, value);
        },
      ),
    );
  }

  Widget emailIdWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _emailIdController,
        hint: Localization.of(context).emailId,
        label: Localization.of(context).emailId,
        type: TextInputType.emailAddress,
        focusNode: _emailIdFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _emailIdFocus.unfocus();
          FocusScope.of(context).requestFocus(_phoneNumberFocus);
        },
        validateFunction: (value) {
          return Utils.isValidEmail(context, value);
        },
      ),
    );
  }

  Widget lastNameWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _lastNameController,
        hint: Localization.of(context).lastName,
        label: Localization.of(context).lastName,
        type: TextInputType.text,
        maxLength: 40,
        textInputFormatter: [
          FilteringTextInputFormatter(nameRegex(), allow: true),
        ],
        focusNode: _lastNameFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _lastNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_emailIdFocus);
        },
        validateFunction: (value) {
          return Utils.isEmpty(
              context, value, Localization.of(context).errorlastName);
        },
      ),
    );
  }

  Widget firstNameWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingXLarge),
      child: PaymishTextField(
        controller: _firstNameController,
        hint: Localization.of(context).firstName,
        label: Localization.of(context).firstName,
        type: TextInputType.text,
        focusNode: _firstNameFocus,
        maxLength: 40,
        textInputAction: TextInputAction.next,
        textInputFormatter: [
          FilteringTextInputFormatter(nameRegex(), allow: true),
        ],
        onFieldSubmitted: (_) {
          _firstNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_lastNameFocus);
        },
        validateFunction: (value) {
          return Utils.isEmpty(
              context, value, Localization.of(context).errorFirstName);
        },
      ),
    );
  }

  // profile update code
  Future<void> _savePressed(BuildContext context) async {
    if (_key.currentState?.validate() ?? false) {
      _firstNameFocus.unfocus();
      _lastNameFocus.unfocus();
      _emailIdFocus.unfocus();
      _phoneNumberFocus.unfocus();
      _businessNameFocus.unfocus();
      _descriptionFocus.unfocus();
      _key.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      await UserApiManager()
          .editProfile(ReqEditProfile(
        email: _emailIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        mobile: _phoneNumberController.text.trim(),
        businessDescription: _descriptionController.text.trim(),
        businessName: _businessNameController.text.trim(),
      ))
          .then((value) async {
        // If API response is SUCCESS
        await _storeDefaults();
        ProgressDialogUtils.dismissProgressDialog();
        // update profile response (success/failure)
        await DialogUtils.displayToast(value.message ?? '');
        // If mobile change, logout and update preference
        if ((value.data?.isMobileChanged ?? 0) == 1) {
          await _logOut(context, value.data?.isMobileChanged ?? 0);
        }
      }).catchError((dynamic e) {
        // If API response is FAILURE or ANY EXCEPTION
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      });
    }
  }

  // Update of Shared Preference Values
  Future _storeDefaults() async {
    await setString(PreferenceKey.mobile, _phoneNumberController.text.trim());
    await setString(PreferenceKey.email, _emailIdController.text.trim());
    await setString(PreferenceKey.firstName, _firstNameController.text.trim());
    await setString(PreferenceKey.lastName, _lastNameController.text.trim());
    // when role is agent or merchant, description to be stored in preference
    if (getString(PreferenceKey.role) != DicParams.roleUser) {
      await setString(PreferenceKey.businessDescription,
          _descriptionController.text.trim());
      await setString(
          PreferenceKey.businessName, _businessNameController.text.trim());
    }
  }

  // When phone number is changed, LOGOUT and Redirect to OTP verification
  Future _logOut(BuildContext context, int isMobileChanged) async {
    // Only Update preference and navigation if mobile is changed
    if (isMobileChanged == 1) {
      await clearAfterEditProfile();
      await NavigationUtils.push(context, routeLoginVerifyOTP, arguments: {
        NavigationParams.phoneNumber: _phoneNumberController.text.trim(),
        NavigationParams.type: DicParams.editProfileMobile,
        NavigationParams.isFromAuth: false
      });
    }
  }
}
