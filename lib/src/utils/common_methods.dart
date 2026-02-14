import 'package:flutter/material.dart';

import '../apis/base_model.dart';
import '../ui/auth/introduction/introduction.dart';
import '../ui/profile/uploaddocuments/upload_document.dart';
import '../ui/tabbar/main_tabbar.dart';
import '../ui/tabbar/merchant_main_tabbar.dart';
import 'app_config.dart';
import 'constants.dart';
import 'dialog_utils.dart';
import 'enum_utils.dart';
import 'image_constants.dart';
import 'keychain_utils.dart';
import 'localization/localization.dart';
import 'navigation.dart';
import 'navigation_params.dart';
import 'preference_key.dart';
import 'preference_utils.dart';

bool checkSessionExpire(ResBaseModel baseModel, BuildContext context) {
  if (baseModel.code == 401) {
    DialogUtils.showOkCancelAlertDialog(
        context: context,
        message: baseModel.error ?? '',
        okButtonTitle: Localization.of(context).ok,
        okButtonAction: () async {
          await logoutAndClearPreference();
          await NavigationUtils.pushAndRemoveUntil(context, routeLogin);
        },
        cancelButtonTitle: Localization.of(context).cancel,
        cancelButtonAction: () {},
        isCancelEnable: false);
    return true;
  } else {
    return false;
  }
}

bool isUserApp() {
  if (getEnvironment() == Environment.userDev ||
      getEnvironment() == Environment.userStage ||
      getEnvironment() == Environment.userProd) {
    return true;
  }
  return false;
}

RegExp nameRegex() {
  return RegExp("[a-zA-Z]");
}

RegExp amountRegex() {
  return RegExp("[0-9]");
}

Widget gotoNextScreen() {
  final preferenceToken = getString(PreferenceKey.token);
  if (preferenceToken.isNotEmpty) {
    if (isUserApp()) {
      if (getBool(PreferenceKey.isDocumentUploaded) == false &&
          getString(PreferenceKey.role) == UserType.agent.getName()) {
        return const UploadDocumentScreen(isFromUpload: true);
      } else {
        return const MainTabBar();
      }
    } else {
      if (getBool(PreferenceKey.isDocumentUploaded) == false) {
        return const UploadDocumentScreen(isFromUpload: true);
      } else {
        return MerchantMainTabBar();
      }
    }
  } else {
    // To show intro screen only once
    return const IntroductionScreen();
  }
}

Future<void> logoutAndClearPreference() async {
  final isFingerPrintEnabled = getBool(PreferenceKey.isFingerPrintEnabled);
  final isSkipContactPermission =
      getBool(PreferenceKey.isSkipContactPermission);
  final isSkipFingerPrintPermission =
      getBool(PreferenceKey.isSkipFingerPrintPermission);
  final mobile = getString(PreferenceKey.mobile);
  final deviceId = getInt(PreferenceKey.deviceId);
  await clear();
  await setBool(PreferenceKey.isFingerPrintEnabled, isFingerPrintEnabled);
  await setBool(PreferenceKey.isSkipContactPermission, isSkipContactPermission);
  await setBool(
      PreferenceKey.isSkipFingerPrintPermission, isSkipFingerPrintPermission);
  await setString(PreferenceKey.mobile, mobile);
  await setBool(PreferenceKey.isLogin, false);
  await setInt(PreferenceKey.deviceId, deviceId);
}

Future<void> clearAfterEditProfile() async {
  final isSkipContactPermission =
      getBool(PreferenceKey.isSkipContactPermission);
  await clear();
  await deleteKeyChainValue(
      key: isUserApp() ? PreferenceKey.mobile : PreferenceKey.merchantMobile);
  await deleteKeyChainValue(
      key: isUserApp()
          ? PreferenceKey.password
          : PreferenceKey.merchantPassword);
  await setBool(PreferenceKey.isSkipContactPermission, isSkipContactPermission);
  await setBool(PreferenceKey.isLogin, false);
}

void openTransactionDetailsDialog(BuildContext context, String screenType) {
  DialogUtils.showOkCancelAlertDialog(
      context: context,
      message: Localization.of(context).errorSetUpTransactionDetails,
      okButtonTitle: Localization.of(context).ok,
      okButtonAction: () => {
            if (screenType == routeWalletSetup)
              {walletScreen(context)}
            else if (screenType == routeCompleteKYC)
              {kycScreen(context)}
            else if (screenType == routeTransactionPinSetup)
              {transactionPin(context)}
            else
              {() {}}
          },
      cancelButtonTitle: Localization.of(context).cancel,
      cancelButtonAction: () {},
      isCancelEnable: true);
}

Future walletScreen(BuildContext context) {
  return NavigationUtils.push(context, routeWalletSetup,
      arguments: {NavigationParams.showBackButton: true});
}

Future kycScreen(BuildContext context) {
  return NavigationUtils.push(context, routeCompleteKYC, arguments: {
    NavigationParams.showBackButton: true,
    NavigationParams.completeTransactionDetails: true
  });
}

Future transactionPin(BuildContext context) {
  return NavigationUtils.push(context, routeTransactionPinSetup,
      arguments: {NavigationParams.showBackButton: true});
}

bool isAccountApproved(BuildContext context) {
  if (getInt(PreferenceKey.isApprovedByAdmin) == 0) {
    DialogUtils.displayToast(Localization.of(context).msgAccountNotApproved);
    return false;
  } else {
    return true;
  }
}

bool checkImageType(String image) {
  if (image.contains(ImageConstants.labelJpg) ||
      image.contains(ImageConstants.labelJpeg) ||
      image.contains(ImageConstants.labelPng)) {
    return true;
  } else {
    return false;
  }
}
