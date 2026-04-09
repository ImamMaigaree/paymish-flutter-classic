import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/fcm_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/keychain_utils.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';
import '../signup/verify_otp/model/req_resend_otp.dart';
import 'model/req_add_device.dart';
import 'model/req_login.dart';
import 'model/res_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final LocalAuthentication _auth = LocalAuthentication();
  final GlobalKey<FormState> _key = GlobalKey();
  String _deviceToken = "";

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _authenticate() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: Localization.of(context).labelAuthWithFingerPrint,
        biometricOnly: true,
      );
      if (authenticated) {
        _phoneNumberController.text = await readKeyChainValue(
          key: isUserApp()
              ? PreferenceKey.mobile
              : PreferenceKey.merchantMobile,
        );
        _passwordController.text = await readKeyChainValue(
          key: isUserApp()
              ? PreferenceKey.password
              : PreferenceKey.merchantPassword,
        );
        _loginPressed();
      }
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled') {
        DialogUtils.displaySnackBar(message: e.code.toString());
      } else {
        DialogUtils.displaySnackBar(message: e.message ?? e.code.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      _phoneNumberController.text = getString(PreferenceKey.mobile);
      if (getBool(PreferenceKey.isFingerPrintEnabled) == true) {
        await _authenticate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(ImageConstants.bgLogin, fit: BoxFit.fill),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Form(
            autovalidateMode: AutovalidateMode.disabled,
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _headerLogo(),
                  _headerDetails(context),
                  _getPhoneNumberTextField(),
                  _getPasswordTextField(),
                  _getForgotPasswordButton(),
                  getBool(PreferenceKey.isFingerPrintEnabled) == true
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: spacingXLarge),
                          child: _getFingerPrintAuth(),
                        )
                      : Container(),
                  _getLoginButton(),
                  _getAccountRegister(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: spacingLarge,
                bottom: spacingLarge,
              ),
              child: Text(
                Localization.of(context).signInTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: fontXMLarge,
                  fontFamily: fontFamilyCovesBold,
                  color: ColorUtils.primaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerLogo() {
    return Padding(
      padding: const EdgeInsets.only(
        right: spacingXXXXLarge + spacingXLarge,
        left: spacingLarge,
        top: spacingXXXLarge,
      ),
      child: Image.asset(
        ImageConstants.icLoginLogo,
        fit: BoxFit.contain,
        height: 160,
      ),
    );
  }

  Widget _getPhoneNumberTextField() => Container(
    padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
    child: PaymishTextField(
      textInputAction: TextInputAction.next,
      focusNode: _phoneFocus,
      controller: _phoneNumberController,
      onFieldSubmitted: (_) {
        _phoneFocus.unfocus();
        FocusScope.of(context).requestFocus(_passwordFocus);
      },
      maxLength: 10,
      prefixCountryCode: countryCode,
      type: TextInputType.phone,
      isPrefixCountryCode: true,
      hint: Localization.of(context).mobileNumber,
      label: Localization.of(context).mobileNumber,
      isLeadingIcon: true,
      leadingIcon: ImageConstants.icNigeria,
      validateFunction: (value) {
        return Utils.isMobileNumberValid(context, value ?? '');
      },
    ),
  );

  Widget _getPasswordTextField() => Container(
    padding: const EdgeInsets.only(
      left: spacingLarge,
      right: spacingLarge,
      top: spacingXXLarge,
    ),
    child: PaymishTextField(
      textInputAction: TextInputAction.done,
      focusNode: _passwordFocus,
      controller: _passwordController,
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
        return Utils.isValidPassword(context, value ?? '');
      },
    ),
  );

  Widget _getForgotPasswordButton() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      TextButton(
        onPressed: _forgotPasswordPressed,
        child: Text(
          Localization.of(context).forgotPassword,
          style: const TextStyle(
            fontSize: fontMedium,
            fontFamily: fontFamilyPoppinsRegular,
          ),
        ),
      ),
    ],
  );

  Widget _getAccountRegister() => Container(
    margin: const EdgeInsets.only(top: spacingXXLarge, bottom: spacingMedium),
    child: Column(
      children: [
        RichText(
          text: TextSpan(
            text: Localization.of(context).dontHaveAnAccount,
            style: const TextStyle(
              color: Colors.black,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsLight,
            ),
            children: <TextSpan>[
              TextSpan(
                text: Localization.of(context).signUpTitle,
                style: const TextStyle(
                  fontSize: fontMedium,
                  fontFamily: fontFamilyPoppinsMedium,
                  fontWeight: FontWeight.w700,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    isUserApp()
                        ? NavigationUtils.push(
                            context,
                            routeUserSignUp,
                            arguments: {
                              NavigationParams.isFromIntroduction: false,
                            },
                          )
                        : NavigationUtils.push(
                            context,
                            routeMerchantSignUp,
                            arguments: {
                              NavigationParams.isFromIntroduction: false,
                            },
                          );
                  },
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _getFingerPrintAuth() {
    return FloatingActionButton(
      elevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      heroTag: "",
      backgroundColor: Colors.transparent,
      onPressed: _authenticate,
      child: Image.asset(ImageConstants.icFingerPrint),
    );
  }

  Widget _getLoginButton() => Padding(
    padding: const EdgeInsets.only(left: spacingLarge, right: spacingLarge),
    child: PaymishPrimaryButton(
      buttonText: Localization.of(context).signInTitle,
      isBackground: true,
      onButtonClick: () async {
        if (_key.currentState?.validate() ?? false) {
          _key.currentState?.save();
          await _loginPressed();
        }
      },
    ),
  );

  Future<void> _loginPressed() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final permission = await _requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      DialogUtils.showOkCancelAlertDialog(
        context: context,
        message: Localization.of(context).alertPermissionNotRestricted,
        cancelButtonTitle: Localization.of(context).cancel,
        okButtonTitle: Localization.of(context).ok,
        okButtonAction: AppSettings.openAppSettings,
        cancelButtonAction: () {},
      );
    } else {
      await _addDeviceApiCall();
    }
  }

  Future<void> _addDeviceApiCall() async {
    ProgressDialogUtils.showProgressDialog(context);
    try {
      registerNotification(context);
      var deviceType = Platform.operatingSystem;
      var browserInfo = "";
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        browserInfo = androidInfo.model;
        deviceType = Platform.operatingSystem;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        browserInfo = iosInfo.utsname.machine;
      } else {
        DialogUtils.showAlertDialog(
          context,
          Localization.of(context).errorSomethingWentWrong,
        );
      }
      Position? position;
      try {
        final serviceStatus = await _isLocationServiceEnabled();
        if (serviceStatus) {
          position = await _getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        }
      } catch (e) {
        position = null;
      }
      // Fallback to a valid default location if services are unavailable.
      final double latitude = position?.latitude ?? 6.5244;
      final double longitude = position?.longitude ?? 3.3792;

      final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

      final token = await getFcmTokenSafely();
      if (mounted) {
        setState(() {
          _deviceToken = token;
        });
      } else {
        _deviceToken = token;
      }

      final value = await UserApiManager().addDevice(
        ReqAddDevice(
          deviceToken: _deviceToken,
          deviceType: deviceType,
          lat: latitude,
          long: longitude,
          browserInfo: browserInfo,
          timeZone: currentTimeZone,
        ),
      );
      await callLoginApi(value.deviceId ?? 0);
    } catch (e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        debugPrint(e.error);
        DialogUtils.showAlertDialog(context, e.error ?? '');
      } else {
        debugPrint("LOGIN: addDevice flow failed error=$e");
        DialogUtils.showAlertDialog(
          context,
          Localization.of(context).errorSomethingWentWrong,
        );
      }
    }
  }

  Future<void> callLoginApi(int deviceId) async {
    debugPrint(
      "LOGIN: isUserApp=${isUserApp()} userType=${isUserApp() ? '' : UserType.merchant.getName()}",
    );
    debugPrint(
      "LOGIN: mobile=${_phoneNumberController.text.trim()} deviceId=$deviceId",
    );
    await UserApiManager()
        .login(
          ReqLogin(
            mobile: _phoneNumberController.text.trim(),
            password: _passwordController.text.trim(),
            deviceId: deviceId,
            userType: isUserApp() ? '' : UserType.merchant.getName(),
          ),
        )
        .then((value) async {
          debugPrint(
            "LOGIN: success userId=${value.user?.id} role=${value.user?.role} approved=${value.user?.isApprovedByAdmin}",
          );
          final user = value.user;
          if (user == null) {
            DialogUtils.showAlertDialog(
              context,
              Localization.of(context).errorSomethingWentWrong,
            );
            ProgressDialogUtils.dismissProgressDialog();
            return;
          }
          if (isUserApp()) {
            if (user.role == DicParams.roleMerchant) {
              DialogUtils.showAlertDialog(
                context,
                Localization.of(context).errorUserApp,
              );
            } else {
              await _removeKeyChainValue();
              await _storeKeyChainValues(value: value);
              await _storeDefaults(value: value);
              if (user.isDocumentUploaded == false) {
                await NavigationUtils.pushAndRemoveUntil(
                  context,
                  routeUploadDocuments,
                  arguments: {DicParams.isFromUpload: true},
                );
              } else if (user.kycStatus == DicParams.notVerified) {
                await NavigationUtils.pushAndRemoveUntil(
                  context,
                  routeCompleteKYC,
                  arguments: {
                    NavigationParams.showBackButton: false,
                    NavigationParams.completeTransactionDetails: false,
                  },
                );
              } else {
                await NavigationUtils.pushAndRemoveUntil(context, routeMainTab);
              }
            }
          } else {
            if (user.role == DicParams.roleMerchant) {
              await _removeMerchantKeyChainValue();
              await _storeMerchantKeyChainValues(value: value);
              await _storeDefaults(value: value);
              if (user.isDocumentUploaded == false) {
                await NavigationUtils.pushAndRemoveUntil(
                  context,
                  routeUploadDocuments,
                  arguments: {DicParams.isFromUpload: true},
                );
              } else if (user.kycStatus == DicParams.notVerified) {
                await NavigationUtils.pushAndRemoveUntil(
                  context,
                  routeCompleteKYC,
                  arguments: {
                    NavigationParams.showBackButton: false,
                    NavigationParams.completeTransactionDetails: false,
                  },
                );
              } else {
                await NavigationUtils.pushAndRemoveUntil(
                  context,
                  routeMerchantMainTab,
                );
              }
            } else {
              DialogUtils.showAlertDialog(
                context,
                Localization.of(context).errorMerchantApp,
              );
            }
          }
          ProgressDialogUtils.dismissProgressDialog();
        })
        .catchError((dynamic e) {
          ProgressDialogUtils.dismissProgressDialog();
          if (e is ResBaseModel) {
            debugPrint(
              "LOGIN: failed code=${e.code} error=${e.error} message=${e.message} mobileVerified=${e.errorLogin?.isMobileVerified} emailVerified=${e.errorLogin?.isEmailVerified}",
            );
          } else {
            debugPrint("LOGIN: failed error=$e");
            DialogUtils.showAlertDialog(
              context,
              Localization.of(context).errorSomethingWentWrong,
            );
          }
          if (e is ResBaseModel) {
            final errorLogin = e.errorLogin;
            if ((errorLogin?.isMobileVerified ?? 1) == 0) {
              DialogUtils.showOkCancelAlertDialog(
                context: context,
                message: Localization.of(context).errorMobileNotVerified,
                okButtonTitle: Localization.of(context).ok,
                okButtonAction: () => _okButtonClicked(context, 0),
                cancelButtonTitle: Localization.of(context).cancel,
                cancelButtonAction: () {},
                isCancelEnable: true,
              );
            } else if ((errorLogin?.isEmailVerified ?? 1) == 0) {
              DialogUtils.showOkCancelAlertDialog(
                context: context,
                message: Localization.of(context).errorEmailNotVerified,
                okButtonTitle: Localization.of(context).ok,
                okButtonAction: () => _okButtonClicked(context, 1),
                cancelButtonTitle: Localization.of(context).cancel,
                cancelButtonAction: () {},
                isCancelEnable: true,
              );
            } else {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
  }

  void _okButtonClicked(BuildContext context, int sendEmail) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .resendOTP(
          ReqResendOtp(
            mobile: _phoneNumberController.text.trim(),
            type: DicParams.signUpMobile,
            sendEmail: sendEmail,
          ),
        )
        .then((value) {
          ProgressDialogUtils.dismissProgressDialog();
          DialogUtils.displayToast(value.message ?? '');
          if (sendEmail == 0) {
            NavigationUtils.push(
              context,
              routeLoginVerifyOTP,
              arguments: {
                NavigationParams.phoneNumber: _phoneNumberController.text
                    .trim(),
                NavigationParams.type: DicParams.signUpMobile,
                NavigationParams.isFromAuth: true,
              },
            );
          }
        })
        .catchError((dynamic e) {
          ProgressDialogUtils.dismissProgressDialog();
          if (e is ResBaseModel) {
            if (!checkSessionExpire(e, context)) {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
  }

  Future<void> _storeDefaults({required ResLogin value}) async {
    final user = value.user;
    await setInt(PreferenceKey.id, user?.id ?? 0);
    await setString(PreferenceKey.mobile, user?.mobile ?? '');
    await setString(PreferenceKey.role, user?.role ?? '');
    await setString(PreferenceKey.email, user?.email ?? '');
    await setString(PreferenceKey.businessName, user?.businessName ?? '');
    await setString(PreferenceKey.firstName, user?.firstName ?? '');
    await setString(PreferenceKey.lastName, user?.lastName ?? '');
    await setString(PreferenceKey.qrCode, user?.qrCode ?? '');
    await setString(PreferenceKey.token, value.token ?? '');
    await setBool(PreferenceKey.isLogin, true);
    await setInt(PreferenceKey.deviceId, user?.deviceId ?? 0);
    await setString(PreferenceKey.kycStatus, user?.kycStatus ?? '');
    await setInt(PreferenceKey.isTransactionPin, user?.isTransactionPin ?? 0);
    await setInt(PreferenceKey.isBankAccount, user?.isBankAccount ?? 0);
    await setString(PreferenceKey.profilePicture, user?.profilePicture ?? '');
    await setString(PreferenceKey.bvnNumber, user?.bvnNumber ?? '');
    await setString(
      PreferenceKey.businessCategories,
      user?.businessCategories ?? '',
    );
    await setString(
      PreferenceKey.businessDescription,
      user?.businessDescription ?? '',
    );
    await setInt(PreferenceKey.isApprovedByAdmin, user?.isApprovedByAdmin ?? 0);
    await setBool(
      PreferenceKey.isDocumentUploaded,
      user?.isDocumentUploaded ?? false,
    );
  }

  Future _storeKeyChainValues({required ResLogin value}) async {
    await writeKeyChainValue(
      key: PreferenceKey.mobile,
      value: value.user?.mobile ?? '',
    );
    await writeKeyChainValue(
      key: PreferenceKey.password,
      value: _passwordController.text,
    );
  }

  Future _storeMerchantKeyChainValues({required ResLogin value}) async {
    await writeKeyChainValue(
      key: PreferenceKey.merchantMobile,
      value: value.user?.mobile ?? '',
    );
    await writeKeyChainValue(
      key: PreferenceKey.merchantPassword,
      value: _passwordController.text,
    );
  }

  Future _removeKeyChainValue() async {
    if (_phoneNumberController.text !=
            await readKeyChainValue(key: PreferenceKey.mobile) &&
        _passwordController.text !=
            await readKeyChainValue(key: PreferenceKey.password)) {
      await clearAfterEditProfile();
    }
  }

  Future _removeMerchantKeyChainValue() async {
    if (_phoneNumberController.text !=
            await readKeyChainValue(key: PreferenceKey.merchantMobile) &&
        _passwordController.text !=
            await readKeyChainValue(key: PreferenceKey.merchantPassword)) {
      await clearAfterEditProfile();
    }
  }

  void _forgotPasswordPressed() {
    NavigationUtils.push(context, routeForgotPassword);
  }

  Future<LocationPermission> _requestPermission() {
    return Geolocator.requestPermission();
  }

  Future<bool> _isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<Position> _getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  }) {
    return Geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }
}
