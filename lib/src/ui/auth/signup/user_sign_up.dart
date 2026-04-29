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
  final FocusNode _dateOfBirthFocus = FocusNode();
  final FocusNode _residentialAddressFocus = FocusNode();
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
  String? _dateOfBirth;
  String? _gender;
  String? _residentialAddress;
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
  final List<String> _genderOptions = ["male", "female"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _dateOfBirthFocus.dispose();
    _residentialAddressFocus.dispose();
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
                      _getDateOfBirthTextField(),
                      _getGenderDropDown(),
                      _getResidentialAddressTextField(),
                      _getEmailTextField(),
                      _getMobileTextField(),
                      _getPasswordTextField(),
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
          Localization.of(context).createAccountLabelUser,
          style: const TextStyle(
            color: ColorUtils.blackColorLight,
            fontSize: fontLarge,
          ),
        ),
      );

  Widget _getDateOfBirthTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _dateOfBirthFocus,
        onSaved: (value) {
          _dateOfBirth = (value ?? '').trim();
        },
        onFieldSubmitted: (_) {
          _dateOfBirthFocus.unfocus();
          FocusScope.of(context).requestFocus(_residentialAddressFocus);
        },
        type: TextInputType.datetime,
        hint: "Date of Birth (YYYY-MM-DD)",
        label: "Date of Birth (YYYY-MM-DD)",
        validateFunction: (value) {
          final input = (value ?? '').trim();
          if (input.isEmpty) {
            return "Date of birth is required";
          }
          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) {
            return "Use YYYY-MM-DD format";
          }
          final parsed = DateTime.tryParse(input);
          if (parsed == null) {
            return "Enter a valid date";
          }
          if (parsed.isAfter(DateTime.now())) {
            return "Date of birth cannot be in the future";
          }
          return null;
        },
      ),
    );
  }

  Widget _getGenderDropDown() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        style: const TextStyle(
          color: ColorUtils.primaryColor,
          fontSize: fontLarge,
          fontFamily: fontFamilyPoppinsRegular,
        ),
        hint: const Text(
          "Gender",
          style: TextStyle(color: ColorUtils.primaryColor),
        ),
        initialValue: _gender,
        items: _genderOptions.map((value) {
          final label = value == "male" ? "Male" : "Female";
          return DropdownMenuItem<String>(
            value: value,
            child: Text(label),
          );
        }).toList(),
        onChanged: (String? newValueSelected) {
          setState(() {
            _gender = newValueSelected;
          });
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Gender is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _getResidentialAddressTextField() {
    return Container(
      padding: const EdgeInsets.only(
          top: spacingSmall, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        textInputAction: TextInputAction.next,
        focusNode: _residentialAddressFocus,
        onSaved: (value) {
          _residentialAddress = (value ?? '').trim();
        },
        onFieldSubmitted: (_) {
          _residentialAddressFocus.unfocus();
          FocusScope.of(context).requestFocus(_emailFocus);
        },
        type: TextInputType.text,
        hint: "Residential Address",
        label: "Residential Address",
        maxLength: 255,
        validateFunction: (value) {
          final input = (value ?? '').trim();
          if (input.isEmpty) {
            return "Residential address is required";
          }
          if (input.length < 5) {
            return "Enter a valid address";
          }
          return null;
        },
      ),
    );
  }

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
          FocusScope.of(context).requestFocus(_dateOfBirthFocus);
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
    if (_userFormKey.currentState?.validate() ?? false) {
      _userFormKey.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .signUp(ReqSignUp(
              firstName: (_firstName ?? '').trim(),
              lastName: (_lastName ?? '').trim(),
              dateOfBirth: (_dateOfBirth ?? '').trim(),
              gender: (_gender ?? '').trim(),
              residentialAddress: (_residentialAddress ?? '').trim(),
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
        await DialogUtils.displayToast(Localization.of(context).msgSignUpSuccess);
      }).catchError((dynamic e) {
        if (e is ResBaseModel) {
          debugPrint(e.error);
        }
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.showAlertDialog(context, e.error ?? '');
      });
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
          ],
        ),
      );

  void _cmsPressed({bool isPrivacyPolicy = false}) {
    NavigationUtils.push(context, routePrivacyPolicy, arguments: {
      NavigationParams.isPrivacyPolicy: isPrivacyPolicy,
    });
  }
}
