import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:page_indicator/page_indicator.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/keychain_utils.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../login/model/req_login.dart';
import '../login/model/res_login.dart';
import '../signup/verify_otp/model/req_resend_otp.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  late final PageController _controller;
  final LocalAuthentication _auth = LocalAuthentication();
  final GlobalKey<PageContainerState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: <Widget>[
          const Image(
            image: AssetImage(ImageConstants.bgLogin),
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.70,
                child: PageIndicatorContainer(
                  key: _key,
                  align: IndicatorAlign.bottom,
                  length: 4,
                  indicatorSpace: spacingSmall,
                  indicatorColor: ColorUtils.lightGrey,
                  indicatorSelectorColor: ColorUtils.primaryColor,
                  child: PageView(
                    controller: _controller,
                    reverse: false,
                    children: <Widget>[
                     isUserApp()==true?
                      _getIntroScreen(
                          ImageConstants.icUserIntro1,
                          Localization.of(context).intro1User,
                          Localization.of(context).desc1User):
                      _getIntroScreen(
                          ImageConstants.icMerchantIntro1,
                          Localization.of(context).intro1Merchant,
                          Localization.of(context).desc1Merchant),
                     isUserApp()==true?
                      _getIntroScreen(
                          ImageConstants.icUserIntro2,
                          Localization.of(context).intro2User,
                          Localization.of(context).desc2User):
                      _getIntroScreen(
                          ImageConstants.icMerchantIntro2,
                          Localization.of(context).intro2Merchant,
                          Localization.of(context).desc2Merchant),
                      isUserApp()==true?
                      _getIntroScreen(
                          ImageConstants.icUserIntro3,
                          Localization.of(context).intro3User,
                          Localization.of(context).desc3User):
                      _getIntroScreen(
                          ImageConstants.icMerchantIntro3,
                          Localization.of(context).intro3Merchant,
                          Localization.of(context).desc3Merchant),
                      isUserApp()==true?
                      _getIntroScreen(
                          ImageConstants.icUserIntro4,
                          Localization.of(context).intro4User,
                          Localization.of(context).desc4User):
                      _getIntroScreen(
                          ImageConstants.icMerchantIntro4,
                          Localization.of(context).intro4Merchant,
                          Localization.of(context).desc4Merchant),

                    ],
                  ),
                ),
              ),
              getBool(PreferenceKey.isFingerPrintEnabled) == true
                  ? _getFingerPrintAuth()
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _getSignInButton(),
                  _getSignUpButton(),
                ],
              )
            ],
          ),
        ]),
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
      child: Image.asset(
        ImageConstants.icFingerPrint,
      ),
    );
  }

  Widget _getSignInButton() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
              left: spacingLarge, right: spacingSmall, top: spacingSmall),
          child: PaymishPrimaryButton(
            buttonText: Localization.of(context).signInTitle,
            isBackground: false,
            onButtonClick: _signInButtonPressed,
          ),
        ),
      );

  void _signInButtonPressed() {
    // To show intro screen only once
    NavigationUtils.pushAndRemoveUntil(context, routeLogin);
  }

  Widget _getSignUpButton() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
              left: spacingSmall, right: spacingLarge, top: spacingSmall),
          child: PaymishPrimaryButton(
            buttonText: Localization.of(context).signUpTitle,
            isBackground: false,
            onButtonClick: _signUpButtonPressed,
          ),
        ),
      );

  void _signUpButtonPressed() {
    isUserApp()
        ? NavigationUtils.pushAndRemoveUntil(context, routeUserSignUp,
            arguments: {NavigationParams.isFromIntroduction: true})
        : NavigationUtils.pushAndRemoveUntil(context, routeMerchantSignUp,
            arguments: {NavigationParams.isFromIntroduction: true});
  }

  Widget _getIntroScreen(String image, String introText, String description) =>
      Container(
        padding: const EdgeInsets.fromLTRB(
            spacingXXXLarge, spacingXXXLarge, spacingXXXLarge, spacingSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(image),
            Column(
              children: <Widget>[
                Text(
                  introText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22.0, color: ColorUtils.primaryColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: spacingMedium),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: fontMedium, color: ColorUtils.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _authenticate() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: Localization.of(context).labelAuthWithFingerPrint,
        biometricOnly: true,
      );
      if (authenticated) {
        await _loginPressed();
      }
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled') {
        await DialogUtils.displayToast(e.code.toString());
      } else {
        await DialogUtils.displayToast(e.message ?? e.code.toString());
      }
    }
  }

  Future<void> _loginPressed() async {
    // button click remove all focus
    FocusScope.of(context).requestFocus(FocusNode());
    ProgressDialogUtils.showProgressDialog(context);
    await UserApiManager()
        .login(ReqLogin(
            mobile: await readKeyChainValue(
                key: isUserApp()
                    ? PreferenceKey.mobile
                    : PreferenceKey.merchantMobile),
            password: await readKeyChainValue(
                key: isUserApp()
                    ? PreferenceKey.password
                    : PreferenceKey.merchantPassword),
            deviceId: getInt(PreferenceKey.deviceId),
            userType: isUserApp() ? '' : UserType.merchant.getName()))
        .then((value) async {
      ProgressDialogUtils.dismissProgressDialog();
      if (isUserApp()) {
        await _userNavigation(value);
      } else {
        await _merchantNavigation(value);
      }
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
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
              isCancelEnable: true);
        } else if ((errorLogin?.isEmailVerified ?? 1) == 0) {
          DialogUtils.showOkCancelAlertDialog(
              context: context,
              message: Localization.of(context).errorEmailNotVerified,
              okButtonTitle: Localization.of(context).ok,
              okButtonAction: () => _okButtonClicked(context, 1),
              cancelButtonTitle: Localization.of(context).cancel,
              cancelButtonAction: () {},
              isCancelEnable: true);
        } else {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  Future<void> _userNavigation(ResLogin value) async {
    final user = value.user;
    if (user == null) {
      DialogUtils.showAlertDialog(context, Localization.of(context).errorUserApp);
      return;
    }
    if (user.role == DicParams.roleMerchant) {
      DialogUtils.showAlertDialog(
          context, Localization.of(context).errorUserApp);
    } else {
      await _storeDefaults(value: value);
      if (user.isDocumentUploaded == false) {
        await NavigationUtils.pushAndRemoveUntil(context, routeUploadDocuments,
            arguments: {DicParams.isFromUpload: true});
      } else if (user.kycStatus == DicParams.notVerified) {
        await NavigationUtils.pushAndRemoveUntil(context, routeCompleteKYC,
            arguments: {
              NavigationParams.showBackButton: false,
              NavigationParams.completeTransactionDetails: false
            });
      } else {
        await NavigationUtils.pushAndRemoveUntil(context, routeMainTab);
      }
    }
  }

  Future<void> _merchantNavigation(ResLogin value) async {
    final user = value.user;
    if (user == null) {
      DialogUtils.showAlertDialog(
          context, Localization.of(context).errorMerchantApp);
      return;
    }
    if (user.role == DicParams.roleMerchant) {
      await _storeDefaults(value: value);
      if (user.isDocumentUploaded == false) {
        await NavigationUtils.pushAndRemoveUntil(context, routeUploadDocuments,
            arguments: {DicParams.isFromUpload: true});
      } else if (user.kycStatus == DicParams.notVerified) {
        await NavigationUtils.pushAndRemoveUntil(context, routeCompleteKYC,
            arguments: {
              NavigationParams.showBackButton: false,
              NavigationParams.completeTransactionDetails: false
            });
      } else {
        await NavigationUtils.pushAndRemoveUntil(context, routeMerchantMainTab);
      }
    } else {
      DialogUtils.showAlertDialog(
          context, Localization.of(context).errorMerchantApp);
    }
  }

  Future<void> _okButtonClicked(BuildContext context, int sendEmail) async {
    ProgressDialogUtils.showProgressDialog(context);
    await UserApiManager()
        .resendOTP(ReqResendOtp(
            mobile: await readKeyChainValue(
                key: isUserApp()
                    ? PreferenceKey.mobile
                    : PreferenceKey.merchantMobile),
            type: DicParams.signUpMobile,
            sendEmail: sendEmail))
        .then((value) async {
      ProgressDialogUtils.dismissProgressDialog();
      await DialogUtils.displayToast(value.message ?? '');
      if (sendEmail == 0) {
        await NavigationUtils.push(context, routeLoginVerifyOTP, arguments: {
          NavigationParams.phoneNumber: await readKeyChainValue(
              key: isUserApp()
                  ? PreferenceKey.mobile
                  : PreferenceKey.merchantMobile),
          NavigationParams.type: DicParams.signUpMobile,
          NavigationParams.isFromAuth: true
        });
      }
    }).catchError((dynamic e) {
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
    await setString(
        PreferenceKey.profilePicture, user?.profilePicture ?? '');
    await setString(PreferenceKey.bvnNumber, user?.bvnNumber ?? '');
    await setString(
        PreferenceKey.businessCategories, user?.businessCategories ?? '');
    await setString(
        PreferenceKey.businessDescription, user?.businessDescription ?? '');
    await setInt(PreferenceKey.isApprovedByAdmin, user?.isApprovedByAdmin ?? 0);
    await setBool(
        PreferenceKey.isDocumentUploaded, user?.isDocumentUploaded ?? false);
  }
}
