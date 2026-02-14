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

class UserSignUpScreen extends StatefulWidget {
  final bool isFromIntroduction;

  const UserSignUpScreen({Key? key, this.isFromIntroduction = false})
      : super(key: key);

  @override
  _UserSignUpScreenState createState() => _UserSignUpScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<bool>('isFromIntroduction', isFromIntroduction));
  }
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _businessNameFocus = FocusNode();
  final FocusNode _categoryOfBusinessFocus = FocusNode();
  final FocusNode _decsOfBusinessFocus = FocusNode();

  final FocusNode _agentFirstNameFocus = FocusNode();
  final FocusNode _agentLastNameFocus = FocusNode();
  final FocusNode _agentEmailFocus = FocusNode();
  final FocusNode _agentMobileFocus = FocusNode();
  final FocusNode _agentPasswordFocus = FocusNode();
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _agentFormKey = GlobalKey<FormState>();
  String? _categoryOfBusinessDropDown;
  final __categoryOfBusinessDropDowns = [
    DicParams.categoryTypeIndividual,
    DicParams.categoryTypeCorporate
  ];

  bool _isActiveTypeUser = true;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _mobile;
  String? _password;
  String? _agentEmail;
  String? _agentMobile;
  String? _agentFirstName;
  String? _agentLastName;
  String? _agentPassword;
  String? _businessName;
  String? _decsOfBusiness;
  Color _left = ColorUtils.primaryColor;
  Color _right = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _businessNameFocus.dispose();
    _categoryOfBusinessFocus.dispose();
    _decsOfBusinessFocus.dispose();
    _agentEmailFocus.dispose();
    _agentMobileFocus.dispose();
    _agentPasswordFocus.dispose();
    _agentFirstNameFocus.dispose();
    _agentLastNameFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).createAccount,
        isBackGround: false,
        isHideBackButton: widget.isFromIntroduction,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getScreenTitle(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildMenuBar(context),
                ],
              ),
              Visibility(
                visible: _isActiveTypeUser,
                maintainState: true,
                child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _userFormKey,
                  child: Column(
                    children: <Widget>[
                      _getFirstNameTextField(),
                      _getLastNameTextField(),
                      _getEmailTextField(),
                      _getMobileTextField(),
                      _getPasswordTextField(),
                    ],
                  ),
                ),
              ),
              Visibility(
                maintainState: true,
                visible: !_isActiveTypeUser,
                child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _agentFormKey,
                  child: Column(
                    children: <Widget>[
                      _getBusinessNameTextField(),
                      _getCategoryOfBusinessDropDown(),
                      _getAgentFirstNameTextField(),
                      _getAgentLastNameTextField(),
                      _getAgentEmailTextField(),
                      _getAgentMobileTextField(),
                      _getDescOfBusinessTextField(),
                      _getAgentPasswordTextField(),
                    ],
                  ),
                ),
              ),
              _getNextButton(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getAccountRegister(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getScreenTitle() => Padding(
        padding: const EdgeInsets.only(top: spacingSmall, left: spacingLarge),
        child: Text(
          _isActiveTypeUser
              ? Localization.of(context).createAccountLabelUser
              : Localization.of(context).createAccountLabelAgent,
          style: const TextStyle(
            color: ColorUtils.blackColorLight,
            fontSize: fontLarge,
          ),
        ),
      );

  Widget _getEmailTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
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

  Widget _getAgentEmailTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _agentEmailFocus,
        onSaved: (value) {
          _agentEmail = value ?? '';
        },
        onFieldSubmitted: (_) {
          _agentEmailFocus.unfocus();
          FocusScope.of(context).requestFocus(_agentMobileFocus);
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

  Widget _getMobileTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _mobileFocus,
        onSaved: (value) {
          _mobile = value ?? '';
        },
        onFieldSubmitted: (_) {
          _mobileFocus.unfocus();
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
        maxLength: 10,
        type: TextInputType.phone,
        hint: Localization.of(context).mobileNumber,
        label: Localization.of(context).mobileNumber,
        isLeadingIcon: true,
        leadingIcon: ImageConstants.icNigeria,
        prefixCountryCode: countryCode,
        isPrefixCountryCode: true,
        validateFunction: (value) {
          return Utils.isMobileNumberValid(context, value);
        },
      ),
    );
  }

  Widget _getAgentMobileTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        maxLength: 10,
        textInputAction: TextInputAction.next,
        focusNode: _agentMobileFocus,
        onSaved: (value) {
          _agentMobile = value ?? '';
        },
        onFieldSubmitted: (_) {
          _agentMobileFocus.unfocus();
          FocusScope.of(context).requestFocus(_decsOfBusinessFocus);
        },
        type: TextInputType.phone,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        hint: Localization.of(context).mobileNumber,
        label: Localization.of(context).mobileNumber,
        isLeadingIcon: true,
        leadingIcon: ImageConstants.icNigeria,
        prefixCountryCode: countryCode,
        isPrefixCountryCode: true,
        validateFunction: (value) {
          return Utils.isMobileNumberValid(
            context,
            value,
          );
        },
      ),
    );
  }

  Widget _getFirstNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingXLarge, left: spacingLarge, right: spacingLarge),
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
        textInputFormatter: [
          FilteringTextInputFormatter(nameRegex(), allow: true),
        ],
        type: TextInputType.text,
        hint: Localization.of(context).firstName,
        label: Localization.of(context).firstName,
        maxLength: 40,
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

  Widget _getAgentFirstNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingMedium, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _agentFirstNameFocus,
        onSaved: (value) {
          _agentFirstName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _agentFirstNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_agentLastNameFocus);
        },
        textInputFormatter: [
          FilteringTextInputFormatter(nameRegex(), allow: true),
        ],
        type: TextInputType.text,
        hint: Localization.of(context).firstName,
        label: Localization.of(context).firstName,
        maxLength: 40,
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

  Widget _getBusinessNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingXLarge, left: spacingLarge, right: spacingLarge),
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

  Widget _getCategoryOfBusinessDropDown() {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingSmall, left: spacingLarge, right: spacingLarge),
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
          onChanged: (String? newValueSelected) {
            setState(() {
              _categoryOfBusinessDropDown = newValueSelected;
            });
          },
        ));
  }

  Widget _getDescOfBusinessTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _decsOfBusinessFocus,
        onSaved: (value) {
          _decsOfBusiness = value ?? '';
        },
        onFieldSubmitted: (_) {
          _decsOfBusinessFocus.unfocus();
          FocusScope.of(context).requestFocus(_agentPasswordFocus);
        },
        type: TextInputType.text,
        hint: Localization.of(context).descOfBusiness,
        maxLength: 100,
        label: Localization.of(context).descOfBusiness,
        validateFunction: (value) {
          return Utils.isEmpty(
            context,
            value,
            Localization.of(context).errorDescOfBusiness,
          );
        },
      ),
    );
  }

  Widget _getLastNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _lastNameFocus,
        onSaved: (value) {
          _lastName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _lastNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_emailFocus);
        },
        textInputFormatter: [
          FilteringTextInputFormatter(nameRegex(), allow: true),
        ],
        type: TextInputType.text,
        hint: Localization.of(context).lastName,
        label: Localization.of(context).lastName,
        maxLength: 40,
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

  Widget _getAgentLastNameTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _agentLastNameFocus,
        onSaved: (value) {
          _agentLastName = value ?? '';
        },
        onFieldSubmitted: (_) {
          _agentLastNameFocus.unfocus();
          FocusScope.of(context).requestFocus(_agentEmailFocus);
        },
        textInputFormatter: [
          FilteringTextInputFormatter(nameRegex(), allow: true),
        ],
        type: TextInputType.text,
        hint: Localization.of(context).lastName,
        label: Localization.of(context).lastName,
        maxLength: 40,
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

  Widget _getNextButton() => Column(
        children: [
          termsAndPolicyWidget(),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
            child: PaymishPrimaryButton(
              buttonText: Localization.of(context).next,
              isBackground: true,
              onButtonClick: _nextPressed,
            ),
          ),
        ],
      );

  Widget termsAndPolicyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: spacingSmall),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: Localization.of(context).labelAgreeTermsAndCondition,
            style: const TextStyle(
                fontSize: fontMedium,
                fontFamily: fontFamilyPoppinsLight,
                color: ColorUtils.blackColor,
                fontWeight: FontWeight.w400),
            children: <TextSpan>[
              TextSpan(
                  text: Localization.of(context).termsAndCondition,
                  style: const TextStyle(
                      fontSize: fontMedium, fontWeight: FontWeight.w900),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _cmsPressed(isPrivacyPolicy: false)),
              TextSpan(
                text: Localization.of(context).labelAnd,
              ),
              TextSpan(
                  text: Localization.of(context).privacyPolicy,
                  style: const TextStyle(
                      fontSize: fontMedium, fontWeight: FontWeight.w900),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _cmsPressed(isPrivacyPolicy: true)),
            ]),
      ),
    );
  }

  Widget _getPasswordTextField() => Container(
        padding: const EdgeInsets.only(
            left: spacingLarge,
            right: spacingLarge,
            bottom: spacingSmall,
            top: spacingSmall),
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

  Widget _getAgentPasswordTextField() => Container(
        padding: const EdgeInsets.only(
            left: spacingLarge,
            right: spacingLarge,
            bottom: spacingSmall,
            top: spacingSmall),
        child: PaymishTextField(
          textInputAction: TextInputAction.done,
        focusNode: _agentPasswordFocus,
        onSaved: (value) {
          _agentPassword = value ?? '';
        },
          hint: Localization.of(context).password,
          label: Localization.of(context).password,
          isObscureText: true,
          isPassword: true,
          trailingIcon: ImageConstants.icPasswordEye,
          endIconClick: (_) {},
          onFieldSubmitted: (_) {
            _agentPasswordFocus.unfocus();
          },
          validateFunction: (value) {
            return Utils.isValidPassword(context, value);
          },
        ),
      );

  void _nextPressed() {
    if (_isActiveTypeUser == true) {
      if (_userFormKey.currentState?.validate() ?? false) {
        _userFormKey.currentState?.save();
        ProgressDialogUtils.showProgressDialog(context);
        UserApiManager()
            .signUp(ReqSignUp(
                firstName: (_firstName ?? '').trim(),
                lastName: (_lastName ?? '').trim(),
                email: (_email ?? '').trim(),
                mobile: (_mobile ?? '').trim(),
                password: (_password ?? '').trim(),
                role: DicParams.roleUser))
            .then((value) async {
          ProgressDialogUtils.dismissProgressDialog();
          await clearAfterEditProfile();
          await NavigationUtils.push(context, routeLoginVerifyOTP, arguments: {
            NavigationParams.phoneNumber: (_mobile ?? '').trim(),
            NavigationParams.type: DicParams.signUpMobile,
            NavigationParams.isFromAuth: true
          });
          await DialogUtils.displayToast(
              Localization.of(context).msgSignUpSuccess);
        }).catchError((dynamic e) {
          if (e is ResBaseModel) {
            debugPrint(e.error);
          }
          ProgressDialogUtils.dismissProgressDialog();
          DialogUtils.showAlertDialog(context, e.error ?? '');
        });
      }
    } else {
      if (_agentFormKey.currentState?.validate() ?? false) {
        _agentFormKey.currentState?.save();
        ProgressDialogUtils.showProgressDialog(context);
        UserApiManager()
            .signUp(ReqSignUp(
                firstName: (_agentFirstName ?? '').trim(),
                lastName: (_agentLastName ?? '').trim(),
                businessName: (_businessName ?? '').trim(),
                businessCategories: _categoryOfBusinessDropDown,
                email: (_agentEmail ?? '').trim(),
                mobile: (_agentMobile ?? '').trim(),
                businessDescription: (_decsOfBusiness ?? '').trim(),
                role: DicParams.roleAgent,
                password: (_agentPassword ?? '').trim()))
            .then((value) async {
          ProgressDialogUtils.dismissProgressDialog();
          await clearAfterEditProfile();
          await NavigationUtils.push(context, routeLoginVerifyOTP, arguments: {
            NavigationParams.phoneNumber: (_agentMobile ?? '').trim(),
            NavigationParams.type: DicParams.signUpMobile,
            NavigationParams.isFromAuth: true
          });
          await DialogUtils.displayToast(
              Localization.of(context).msgSignUpSuccess);
        }).catchError((dynamic e) {
          if (e is ResBaseModel) {
            ProgressDialogUtils.dismissProgressDialog();
            DialogUtils.showAlertDialog(context, e.error ?? '');
          }
        });
      }
    }
  }

  Widget _getAccountRegister() => Container(
        margin: const EdgeInsets.only(top: spacingXLarge),
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
            Padding(
              padding: const EdgeInsets.only(
                  top: spacingSmall, bottom: spacingSmall),
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: _isActiveTypeUser
                          ? Localization.of(context).registerAsAgent
                          : Localization.of(context).registerAsUser,
                      style: const TextStyle(
                        fontSize: fontLarge,
                        fontWeight: FontWeight.w500,
                        fontFamily: fontFamilyPoppinsMedium,
                        color: ColorUtils.primaryColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _onTabChange)),
            ),
          ],
        ),
      );

  void _cmsPressed({bool isPrivacyPolicy = false}) {
    NavigationUtils.push(context, routePrivacyPolicy, arguments: {
      NavigationParams.isPrivacyPolicy: isPrivacyPolicy,
    });
  }

  void _onTabChange() {
    _removeFocus();
    setState(() {
      _isActiveTypeUser = !_isActiveTypeUser;

      if (_isActiveTypeUser) {
        _right = Colors.white;
        _left = ColorUtils.primaryColor;
      } else {
        _right = ColorUtils.primaryColor;
        _left = Colors.white;
      }
    });
  }

  void _removeFocus() {
    _firstNameFocus.unfocus();
    _lastNameFocus.unfocus();
    _emailFocus.unfocus();
    _mobileFocus.unfocus();
    _passwordFocus.unfocus();
    _businessNameFocus.unfocus();
    _categoryOfBusinessFocus.unfocus();
    _decsOfBusinessFocus.unfocus();
  }

  Widget _buildMenuBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, spacingLarge, 0, 0),
      child: Container(
        width: 280.0,
        height: socialButtonHeight,
        decoration: const BoxDecoration(
          color: ColorUtils.primaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(9.0),
          ),
        ),
        child: CustomPaint(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: _right == ColorUtils.primaryColor
                        ? ColorUtils.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: TextButton(
                    onPressed: _onTabChange,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      Localization.of(context).labelUser,
                      style: TextStyle(
                        color: _left,
                        fontSize: fontLarge,
                        backgroundColor: _right == ColorUtils.primaryColor
                            ? ColorUtils.primaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              //Container(height: 33.0, width: 1.0, color: Colors.white),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: _left == ColorUtils.primaryColor
                        ? ColorUtils.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: TextButton(
                    onPressed: _onTabChange,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      Localization.of(context).labelAgent,
                      style: TextStyle(
                        color: _right,
                        backgroundColor: _left == ColorUtils.primaryColor
                            ? ColorUtils.primaryColor
                            : Colors.white,
                        fontSize: fontLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
