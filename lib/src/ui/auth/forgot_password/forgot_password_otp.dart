import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/otp_countdown.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/pin_input_text_field.dart';
import '../signup/verify_otp/model/req_resend_otp.dart';
import '../signup/verify_otp/model/req_verify_otp.dart';
import 'model/res_forget_password.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final ResForgotPasswordData model;

  const ForgotPasswordOtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.model,
  }) : super(key: key);

  @override
  _ForgotPasswordOtpScreenState createState() =>
      _ForgotPasswordOtpScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('phoneNumber', phoneNumber));
    properties.add(DiagnosticsProperty<ResForgotPasswordData>('model', model));
  }
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PaymishAppBar(
          title: Localization.of(context).forgotPasswordLabel,
          isBackGround: false,
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
                      forgotPasswordOTPDescription(context),
                      forgotPasswordEnterPasswordWidget(context),
                      forgotPasswordOTPFieldWidget(),
                      forgotPasswordExpiryResendWidget(context),
                    ],
                  ),
                  forgotPasswordSubmitButtonWidget(context)
                ],
              ),
            ),
          ),
        ));
  }

  Widget forgotPasswordSubmitButtonWidget(BuildContext context) {
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

  Widget forgotPasswordExpiryResendWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingXLarge,
          right: spacingXXLarge,
          top: spacingLarge,
          bottom: spacingXXLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).expiresInLabel,
                style: const TextStyle(
                    color: ColorUtils.accentColor, fontSize: fontLarge),
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
                    _controller.reset();
                    _controller.forward();

                    _isCountDownComplete = _resendOTP(context);
                    setState(() {});
                  }
                : null,
            child: Text(
              Localization.of(context).resendOtpLabel,
              style: TextStyle(
                  fontSize: fontLarge,
                  fontFamily: fontFamilyPoppinsRegular,
                  color: _isCountDownComplete
                      ? ColorUtils.primaryColor
                      : ColorUtils.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget forgotPasswordOTPFieldWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: spacingXLarge, right: imageSmall),
      child: PinInputTextField(
        pinLength: 4,
        focusNode: _otpFocus,
        keyboardType: TextInputType.number,
        decoration: _pinDecoration,
        controller: _pinEditingController,
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
    );
  }

  Widget forgotPasswordEnterPasswordWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: 20, bottom: 30, top: spacingLarge),
      child: Text(
        '''${Localization.of(context).enterTheCodeSentOn} $countryCode ${widget.phoneNumber}''',
        style: const TextStyle(
          fontSize: fontMedium,
          fontFamily: fontFamilyPoppinsRegular,
          color: ColorUtils.secondaryColor,
        ),
      ),
    );
  }

  Widget forgotPasswordOTPDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge,
          right: 20,
          bottom: spacingXLarge,
          top: spacingLarge),
      child: Text(
        Localization.of(context).forgotPasswordOTPDescription,
        style: const TextStyle(
            fontSize: fontMedium,
            fontFamily: fontFamilyPoppinsRegular,
            color: ColorUtils.secondaryColor),
      ),
    );
  }

  // Resend OTP
  bool _resendOTP(BuildContext context) {
    final type = widget.model.type ?? '';
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .resendOTP(ReqResendOtp(
            mobile: widget.phoneNumber, type: type, sendEmail: 0))
        .then((value) {
      // If API response is SUCCESS
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
    });
    // to set the CountDown is false (currently incomplete countdown)
    return false;
  }

  // Submit Button: If OTP is verified, redirect to set password screen
  void _submitPressed(BuildContext context) {
    if (_otpPin.length != 4) {
      DialogUtils.displayToast(Localization.of(context).errorEnterOTP);
    } else {
      final type = widget.model.type ?? '';
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .verifyOTPSignUP(ReqVerifyOtp(
              mobile: widget.phoneNumber,
              type: type,
              otp: _otpPin))
          .then((value) {
        // If API response is SUCCESS
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        NavigationUtils.push(context, routeConfirmPassword, arguments: {
          NavigationParams.phoneNumber: widget.phoneNumber.trim(),
          NavigationParams.model: widget.model
        });
      }).catchError((dynamic e) {
        // If API response is FAILURE or ANY EXCEPTION
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          debugPrint(e.error);
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      });
    }
  }
}
