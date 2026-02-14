import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../utils/progress_dialog.dart';
import '../../widgets/paymish_appbar.dart';
import '../../widgets/paymish_menu_list_item.dart';
import '../../widgets/paymish_switch_view.dart';
import 'model/req_account_setting.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({Key? key}) : super(key: key);

  @override
  _AccountSettingScreenState createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  bool _isNotificationChecked = false;
  bool _isEmailNotificationChecked = false;
  bool _isPushNotificationChecked = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _getProfileDetails());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).accountSettings,
        isBackGround: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacingMedium),
        child: Column(
          children: [
            PaymishMenuListItem(
              titleText: Localization.of(context).labelChangePassword,
              onClick: () {
                changePasswordPressed(context);
              },
            ),
            PaymishMenuListItem(
              titleText: Localization.of(context).labelChangeTransactionPIN,
              onClick: () {
                changeTransactionPinPressed(context);
              },
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(spacingTiny),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20.0,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: spacingSmall),
                padding: const EdgeInsets.only(
                    top: spacingXXLarge,
                    bottom: spacingXXLarge,
                    right: spacingMedium,
                    left: spacingMedium),
                child: Column(
                  children: [
                    PaymishSwitchView(
                        title: Localization.of(context).labelNotification,
                        value: _isNotificationChecked,
                        onButtonClick: setNotificationValue),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: spacingXXXLarge, bottom: spacingXXXLarge),
                      child: PaymishSwitchView(
                          title:
                              Localization.of(context).labelEmailNotification,
                          value: _isEmailNotificationChecked,
                          onButtonClick: setEmailNotificationValue),
                    ),
                    PaymishSwitchView(
                        title: Localization.of(context).labelPushNotification,
                        value: _isPushNotificationChecked,
                        onButtonClick: setPushNotificationValue),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void changePasswordPressed(BuildContext context) {
    NavigationUtils.push(context, routeChangePassword);
  }

  void changeTransactionPinPressed(BuildContext context) {
    NavigationUtils.push(context, routeChangePin);
  }

  void setNotificationValue() {
    _updateAccountSettingData(
        !_isNotificationChecked ? 1 : 0, !_isNotificationChecked ? 1 : 0);
  }

  void setEmailNotificationValue() {
    _updateAccountSettingData(!_isEmailNotificationChecked ? 1 : 0,
        _isPushNotificationChecked ? 1 : 0);
  }

  void setPushNotificationValue() {
    _updateAccountSettingData(_isEmailNotificationChecked ? 1 : 0,
        !_isPushNotificationChecked ? 1 : 0);
  }

  // Update Details
  Future<void> _updateAccountSettingData(
      int isEmailNotificationChecked, int isPushNotificationChecked) async {
    await UserApiManager()
        .updateAccountSettings(ReqAccountSetting(
            isEmailNotification: isEmailNotificationChecked,
            isPushNotification: isPushNotificationChecked))
        .then((value) async {
      // If API response is SUCCESS
      ProgressDialogUtils.dismissProgressDialog();
      await DialogUtils.displayToast(value.message ?? '');
      await _updateSharedPref(
          isPushNotificationChecked, isEmailNotificationChecked);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        } else {
          DialogUtils.showAlertDialog(context, e.message ?? '');
          DialogUtils.displayToast(e.error ?? '');
          NavigationUtils.pop(context);
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
  }

  // Get Profile Details
  Future<void> _getProfileDetails() async {
    ProgressDialogUtils.showProgressDialog(context);
    await UserApiManager().getProfile().then((value) async {
      // If API response is SUCCESS
      ProgressDialogUtils.dismissProgressDialog();
      await _updateSharedPref(
          value.data?.isPushNotification ?? 0,
          value.data?.isEmailNotification ?? 0);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        } else {
          DialogUtils.showAlertDialog(context, e.message ?? '');
          DialogUtils.displayToast(e.error ?? '');
          NavigationUtils.pop(context);
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
  }

  Future<void> _updateSharedPref(
      int isPushNotification, int isEmailNotification) async {
    await setInt(PreferenceKey.isPushNotification, isPushNotification);
    await setInt(PreferenceKey.isEmailNotification, isEmailNotification);
    setState(() {
      _isEmailNotificationChecked =
          (getInt(PreferenceKey.isEmailNotification) == 1);

      _isPushNotificationChecked =
          (getInt(PreferenceKey.isPushNotification) == 1);

      _isNotificationChecked =
          (getInt(PreferenceKey.isEmailNotification) == 1 ||
                  getInt(PreferenceKey.isPushNotification) == 1)
              ? true
              : false;
    });
  }
}
