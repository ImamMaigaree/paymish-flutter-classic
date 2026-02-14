import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../apis/apimanager/user_api_manager.dart';
import '../../../../apis/base_model.dart';
import '../../../../utils/color_utils.dart';
import '../../../../utils/common_methods.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dialog_utils.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/localization/localization.dart';
import '../../../../utils/navigation.dart';
import '../../../../utils/preference_key.dart';
import '../../../../utils/preference_utils.dart';
import '../../../../utils/progress_dialog.dart';
import '../../../../widgets/otp_countdown.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../../widgets/paymish_primary_button.dart';
import '../../../../widgets/pin_input_text_field.dart';
import 'model/req_resend_otp.dart';
import 'model/req_verify_otp.dart';

class LoginVerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String type;
  final bool isFromAuth;

  const LoginVerifyOtpScreen(
      {Key? key,
      required this.phoneNumber,
      required this.type,
      this.isFromAuth = false})
      : super(key: key);

  @override
  _LoginVerifyOtpScreenState createState() => _LoginVerifyOtpScreenState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('phoneNumber', phoneNumber));
    properties.add(StringProperty('type', type));
    properties.add(DiagnosticsProperty<bool>('isFromAuth', isFromAuth));
  }
}

class _LoginVerifyOtpScreenState extends State<LoginVerifyOtpScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final TextEditingController _pinEditingController;
  late final PinDecoration _pinDecoration;
  String _otpPin = '';
  bool _isCountDownComplete = false;
  final FocusNode _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pinEditingController = TextEditingController();
    _pinDecoration =
        const UnderlineDecoration(enteredColor: ColorUtils.primaryColor);
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: otpTime));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pinEditingController.dispose();
    super.dispose();
  }

  Future<bool> _willPopCallback() async {
    if (widget.isFromAuth) {
      NavigationUtils.pop(context);
    } else {
      await NavigationUtils.pushAndRemoveUntil(context, routeLogin);
    }
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
        _willPopCallback();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PaymishAppBar(
          title: Localization.of(context).verifyLabel,
          isBackGround: false,
          isFromAuth: widget.isFromAuth,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: spacingLarge,
                            right: spacingLarge,
                            bottom: spacingXLarge,
                            top: spacingLarge),
                        child: Text(
                          Localization.of(context).verifyOTPDescription,
                          style: const TextStyle(
                              fontSize: fontMedium,
                              fontFamily: fontFamilyPoppinsRegular,
                              color: ColorUtils.secondaryColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: spacingLarge,
                            right: 20,
                            bottom: spacingLarge,
                            top: spacingLarge),
                        child: Text(
                          '''${Localization.of(context).enterTheCodeSentOn} $countryCode ${widget.phoneNumber}''',
                          style: const TextStyle(
                            fontSize: fontMedium,
                            fontFamily: fontFamilyPoppinsRegular,
                            color: ColorUtils.secondaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: spacingXLarge, right: imageSmall),
                        child: PinInputTextField(
                          pinLength: 4,
                          decoration: _pinDecoration,
                          controller: _pinEditingController,
                          focusNode: _otpFocus,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onChanged: (pin) {
                            _otpPin = pin;
                          },
                          onSubmit: (pin) {
                            if (pin.length == 4) {
                              _otpPin = pin;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: spacingXLarge,
                          right: spacingXXLarge,
                          top: spacingLarge,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  Localization.of(context).expiresInLabel,
                                  style: const TextStyle(
                                      color: ColorUtils.accentColor,
                                      fontSize: fontLarge),
                                ),
                                Countdown(
                                  animation: StepTween(
                                    begin: otpTime,
                                    end: 0,
                                  ).animate(_controller)
                                    ..addStatusListener((status) {
                                      // callback when countdown completes
                                      if (status == AnimationStatus.completed) {
                                        setState(() {
                                          // update _isCountDownComplete = true,
                                          // when countdown completes
                                          _isCountDownComplete = true;
                                        });
                                      }
                                    }),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: (_isCountDownComplete)
                                  ? () {
                                      // time which is already passed
                                      _controller.reset();
                                      _controller.forward();

                                      // when API send again,
                                      // _isCountDownComplete = false
                                      _isCountDownComplete =
                                          _resendOTP(context);
                                      setState(() {});
                                    }
                                  : null,
                              style:
                                  TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text(
                                Localization.of(context).resendOtpLabel,
                                style: TextStyle(
                                    fontSize: fontMedium,
                                    fontFamily: fontFamilyPoppinsRegular,
                                    color: _isCountDownComplete
                                        ? ColorUtils.primaryColor
                                        : ColorUtils.accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: spacingLarge,
                        right: spacingLarge,
                        bottom: spacingLarge),
                    child: PaymishPrimaryButton(
                      buttonText: Localization.of(context).labelSubmit,
                      isBackground: true,
                      onButtonClick: () => _submitPressed(context),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// submit button click event
  void _submitPressed(BuildContext context) {
    if (_otpPin.length != 4) {
      DialogUtils.displayToast(Localization.of(context).errorEnterOTP);
    } else {
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .verifyOTPSignUP(ReqVerifyOtp(
              mobile: widget.phoneNumber, type: widget.type, otp: _otpPin))
          .then((value) async {
        ProgressDialogUtils.dismissProgressDialog();
        await DialogUtils.displayToast(value.message ?? '');
        if (getBool(PreferenceKey.isLogin)) {
          DialogUtils.showOkCancelAlertDialog(
              context: context,
              message: Localization.of(context).msgVerifyEmailAndLogin,
              okButtonTitle: Localization.of(context).ok,
              okButtonAction: _okButtonClicked,
              cancelButtonTitle: Localization.of(context).cancel,
              cancelButtonAction: _okButtonClicked,
              isCancelEnable: false);
        } else {
          await clearAfterEditProfile();
          await NavigationUtils.pushAndRemoveUntil(context, routeLogin);
        }
      }).catchError((dynamic e) {
        if (e is ResBaseModel) {
          ProgressDialogUtils.dismissProgressDialog();
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
        ProgressDialogUtils.dismissProgressDialog();
      });
    }
  }

  // Resend OTP
  bool _resendOTP(BuildContext context) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .resendOTP(ReqResendOtp(
            mobile: widget.phoneNumber, type: widget.type, sendEmail: 0))
        .then((value) {
      // If API response is SUCCESS
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
    // to set the CountDown is false (currently incomplete countdown)
    return false;
  }

  void _okButtonClicked() {
    NavigationUtils.pushAndRemoveUntil(context, routeLogin);
  }
}
