import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
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
import 'model/req_sign_up.dart';

class MerchantSignUpScreen extends StatefulWidget {
  final bool isFromIntroduction;

  const MerchantSignUpScreen({Key? key, this.isFromIntroduction = false})
      : super(key: key);

  @override
  _MerchantSignUpScreenState createState() => _MerchantSignUpScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<bool>('isFromIntroduction', isFromIntroduction));
  }
}

class _MerchantSignUpScreenState extends State<MerchantSignUpScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _businessNameFocus = FocusNode();
  final FocusNode _categoryOfBusinessFocus = FocusNode();
  final FocusNode _decsOfBusinessFocus = FocusNode();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final __categoryOfBusinessDropDowns = [
    DicParams.categoryTypeIndividual,
    DicParams.categoryTypeCorporate
  ];
  String? _categoryOfBusinessDropDown;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _mobile;
  String? _password;
  String? _businessName;
  String? _decsOfBusiness;

  Size get _preferredSize => const Size.fromHeight(200.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _businessNameFocus.dispose();
    _categoryOfBusinessFocus.dispose();
    _decsOfBusinessFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            widget.isFromIntroduction ? _preferredSize * 0.75 : _preferredSize,
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(spacingXLarge),
                  bottomRight: Radius.circular(spacingXLarge)),
              color: ColorUtils.primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PaymishAppBar(
                title: Localization.of(context).createAccount,
                isBackGround: true,
                isHideBackButton: widget.isFromIntroduction,
              ),
              _getScreenTitle(),
            ],
          ),
        ),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.disabled, key: _key,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _getFirstNameTextField(),
                      _getLastNameTextField(),
                      _getBusinessNameTextField(),
                      _getCategoryOfBusinessDropDown(),
                      _getEmailTextField(),
                      _getMobileTextField(),
                      _getDescOfBusinessTextField(),
                      _getPasswordTextField(),
                    ],
                  ),
                ),
                _getNextButton(),
                _getAccountRegister(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getScreenTitle() => Padding(
        padding: const EdgeInsets.only(left: spacingLarge),
        child: Text(
          Localization.of(context).createAccountLabelUser,
          style: const TextStyle(
            color: ColorUtils.whiteColorLight,
            fontSize: fontLarge,
          ),
        ),
      );

  Widget _getEmailTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      margin: const EdgeInsets.only(top: spacingMedium),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _emailFocus,
        onSaved: (value) {
          _email = value ?? '';
        },
        onFieldSubmitted: (_) {
          _emailFocus.unfocus();
          FocusScope.of(context).requestFocus(_mobileFocus);
        },
        type: TextInputType.emailAddress,
        hint: Localization.of(context).emailAddress,
        label: Localization.of(context).emailAddress,
        validateFunction: (value) {
          return Utils.isValidEmail(context, value);
        },
      ),
    );
  }

  Widget _getCategoryOfBusinessDropDown() {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingMedium, left: spacingLarge, right: spacingLarge),
        child: DropdownButtonFormField(
          isExpanded: true,
          style: const TextStyle(
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsRegular),
          validator: (value) => value == null
              ? Localization.of(context).errorCategoryOfBusiness
              : null,
          hint: Text(
            Localization.of(context).categoryOfBusiness,
            style: const TextStyle(color: ColorUtils.primaryColor),
          ),
          items: __categoryOfBusinessDropDowns.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          initialValue: _categoryOfBusinessDropDown,
          onChanged: (newValueSelected) {
            setState(() {
              _categoryOfBusinessDropDown = newValueSelected;
            });
          },
        ));
  }

  Widget _getMobileTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      margin: const EdgeInsets.only(top: spacingMedium),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _mobileFocus,
        onSaved: (value) {
          _mobile = value ?? '';
        },
        onFieldSubmitted: (_) {
          _mobileFocus.unfocus();
          FocusScope.of(context).requestFocus(_decsOfBusinessFocus);
        },
        type: TextInputType.phone,
        hint: Localization.of(context).mobileNumber,
        label: Localization.of(context).mobileNumber,
        isLeadingIcon: true,
        leadingIcon: ImageConstants.icNigeria,
        prefixCountryCode: countryCode,
        isPrefixCountryCode: true,
        maxLength: 10,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        validateFunction: (value) {
          return Utils.isMobileNumberValid(context, value);
        },
      ),
    );
  }

  Widget _getFirstNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: 35, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _firstNameFocus,
        onSaved: (value) {
          _firstName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _firstNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_lastNameFocus);
        },
        type: TextInputType.text,
        hint: Localization.of(context).firstName,
        label: Localization.of(context).firstName,
        maxLength: 60,
        validateFunction: (value) {
          return Utils.isEmpty(
            context,
            value,
            Localization.of(context).errorFirstName,
          );
        },
      ),
    );
  }

  Widget _getLastNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: 35, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _lastNameFocus,
        onSaved: (value) {
          _lastName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _lastNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_businessNameFocus);
        },
        type: TextInputType.text,
        hint: Localization.of(context).lastName,
        label: Localization.of(context).lastName,
        maxLength: 60,
        validateFunction: (value) {
          return Utils.isEmpty(
            context,
            value,
            Localization.of(context).errorlastName,
          );
        },
      ),
    );
  }

  Widget _getBusinessNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingXXMLarge, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _businessNameFocus,
        onSaved: (value) {
          _businessName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _businessNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_categoryOfBusinessFocus);
        },
        type: TextInputType.text,
        hint: Localization.of(context).businessName,
        label: Localization.of(context).businessName,
        maxLength: 60,
        validateFunction: (value) {
          return Utils.isEmpty(
            context,
            value,
            Localization.of(context).errorBusinessName,
          );
        },
      ),
    );
  }

  Widget _getDescOfBusinessTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingLarge, left: spacingLarge, right: spacingLarge),
      child: TextFormField(
        focusNode: _decsOfBusinessFocus,
        decoration: InputDecoration(
          hintText: Localization.of(context).descOfBusiness,
          counterText: "",
          errorStyle: const TextStyle(color: Colors.red),
          errorBorder: const OutlineInputBorder(),
          hintStyle: const TextStyle(
            fontSize: fontLarge,
            color: ColorUtils.accentColor,
            fontWeight: FontWeight.w500,
          ),
          labelStyle: const TextStyle(
            fontSize: fontLarge,
            color: ColorUtils.primaryColor,
            fontWeight: FontWeight.w500,
            inherit: true,
          ),
          border: const OutlineInputBorder(),
        ),
        maxLength: 100,
        validator: (value) {
          return Utils.isEmpty(
            context,
            value,
            Localization.of(context).errorDescOfBusiness,
          );
        },
        onFieldSubmitted: (_) {
          _decsOfBusinessFocus.unfocus();
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
        onSaved: (value) {
          _decsOfBusiness = value ?? '';
        },
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _getNextButton() => Padding(
        padding: const EdgeInsets.only(
            top: spacingXXXXLarge, left: spacingLarge, right: spacingLarge),
        child: PaymishPrimaryButton(
          buttonText: Localization.of(context).labelSubmit,
          isBackground: true,
          onButtonClick: _nextPressed,
        ),
      );

  Widget _getPasswordTextField() => Container(
        padding: const EdgeInsets.only(
            left: spacingLarge,
            right: spacingLarge,
            bottom: spacingSmall,
            top: spacingXXLarge),
        child: PaymishTextField(
          textInputAction: TextInputAction.done,
          focusNode: _passwordFocus,
        onSaved: (value) {
          _password = value ?? '';
        },
          hint: Localization.of(context).password,
          label: Localization.of(context).password,
          isObscureText: true,
          isPassword: true,
          trailingIcon: ImageConstants.icPasswordEye,
          endIconClick: (_) {},
          onFieldSubmitted: (_) {
            _passwordFocus.unfocus();
          },
          validateFunction: (value) {
            return Utils.isValidPassword(context, value);
          },
        ),
      );

  void _nextPressed() {
    _removeFocus();
    if (_key.currentState?.validate() ?? false) {
      _key.currentState?.save();

      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .signUp(ReqSignUp(
              businessName: (_businessName ?? '').trim(),
              businessCategories: _categoryOfBusinessDropDown,
              email: (_email ?? '').trim(),
              mobile: (_mobile ?? '').trim(),
              firstName: (_firstName ?? '').trim(),
              lastName: (_lastName ?? '').trim(),
              businessDescription: (_decsOfBusiness ?? '').trim(),
              role: DicParams.roleMerchant,
              password: (_password ?? '').trim()))
          .then((value) async {
        ProgressDialogUtils.dismissProgressDialog();
        await clearAfterEditProfile();
        await NavigationUtils.push(context, routeLoginVerifyOTP, arguments: {
          NavigationParams.phoneNumber: (_mobile ?? '').trim(),
          NavigationParams.type: DicParams.signUpMobile,
          NavigationParams.isFromAuth: true
        });
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          debugPrint(e.error);
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      });
    }
  }

  Widget _getAccountRegister() => Container(
        margin:
            const EdgeInsets.only(top: spacingXLarge, bottom: spacingXLarge),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                  text: Localization.of(context).alreadyHaveAccount,
                  style: const TextStyle(
                    fontSize: fontLarge,
                    fontWeight: FontWeight.w300,
                    fontFamily: fontFamilyPoppinsLight,
                    color: ColorUtils.darkGrey1,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: Localization.of(context).signInTitle,
                        style: const TextStyle(
                          fontSize: fontLarge,
                          fontWeight: FontWeight.w700,
                          fontFamily: fontFamilyPoppinsMedium,
                          color: ColorUtils.primaryColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            NavigationUtils.pushAndRemoveUntil(
                                context, routeLogin);
                          })
                  ]),
            ),
          ],
        ),
      );

  void _removeFocus() {
    _emailFocus.unfocus();
    _mobileFocus.unfocus();
    _passwordFocus.unfocus();
    _businessNameFocus.unfocus();
    _categoryOfBusinessFocus.unfocus();
    _decsOfBusinessFocus.unfocus();
  }
}
