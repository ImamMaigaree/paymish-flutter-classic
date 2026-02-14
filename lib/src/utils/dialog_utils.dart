import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/statement_popup.dart';
import 'color_utils.dart';
import 'constants.dart';
import 'dimens.dart';
import 'localization/localization.dart';

class DialogUtils {
  static void showOkCancelAlertDialog({
    required BuildContext context,
    required String message,
    required String okButtonTitle,
    required String cancelButtonTitle,
    required VoidCallback cancelButtonAction,
    required VoidCallback okButtonAction,
    bool isCancelEnable = true,
  }) {
    showDialog(
      barrierDismissible: isCancelEnable,
      context: context,
      builder: (context) {
        if (Platform.isIOS) {
          return PopScope(
            canPop: false,
            child: _showOkCancelCupertinoAlertDialog(
                context,
                message,
                okButtonTitle,
                cancelButtonTitle,
                okButtonAction,
                isCancelEnable,
                cancelButtonAction),
          );
        } else {
          return PopScope(
            canPop: false,
            child: _showOkCancelMaterialAlertDialog(
                context,
                message,
                okButtonTitle,
                cancelButtonTitle,
                okButtonAction,
                isCancelEnable,
                cancelButtonAction),
          );
        }
      },
    );
  }

  static void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        if (Platform.isIOS) {
          return PopScope(
              canPop: false,
              child: _showCupertinoAlertDialog(context, message));
        } else {
          return PopScope(
              canPop: false,
              child: _showMaterialAlertDialog(context, message));
        }
      },
    );
  }

  static CupertinoAlertDialog _showCupertinoAlertDialog(
      BuildContext context, String message) {
    return CupertinoAlertDialog(
      title: Text(Localization.of(context).appName),
      content: Text(
        message,
        style: const TextStyle(
            fontFamily: fontFamilyRobotoLight,
            fontWeight: FontWeight.w600,
            color: ColorUtils.primaryTextColor,
            letterSpacing: 1),
      ),
      actions: _actions(context),
    );
  }

  static AlertDialog _showMaterialAlertDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: Text(Localization.of(context).appName),
      content: Text(
        message,
        style: const TextStyle(
            fontFamily: fontFamilyRobotoLight,
            fontWeight: FontWeight.w600,
            color: ColorUtils.primaryTextColor,
            letterSpacing: 1),
      ),
      actions: _actions(context),
    );
  }

  static AlertDialog _showOkCancelMaterialAlertDialog(
      BuildContext context,
      String message,
      String okButtonTitle,
      String cancelButtonTitle,
      VoidCallback okButtonAction,
      bool isCancelEnable,
      VoidCallback cancelButtonAction) {
    return AlertDialog(
      title: Text(Localization.of(context).appName),
      content: Text(message),
      actions: _okCancelActions(
        context: context,
        okButtonTitle: okButtonTitle,
        cancelButtonTitle: cancelButtonTitle,
        okButtonAction: okButtonAction,
        isCancelEnable: isCancelEnable,
        cancelButtonAction: cancelButtonAction,
      ),
    );
  }

  static CupertinoAlertDialog _showOkCancelCupertinoAlertDialog(
    BuildContext context,
    String message,
    String okButtonTitle,
    String cancelButtonTitle,
    VoidCallback okButtonAction,
    bool isCancelEnable,
    VoidCallback cancelButtonAction,
  ) {
    return CupertinoAlertDialog(
        title: Text(Localization.of(context).appName),
        content: Text(message),
        actions: isCancelEnable
            ? _okCancelActions(
                context: context,
                okButtonTitle: okButtonTitle,
                cancelButtonTitle: cancelButtonTitle,
                okButtonAction: okButtonAction,
                isCancelEnable: isCancelEnable,
                cancelButtonAction: cancelButtonAction,
              )
            : _okAction(
                context: context,
                okButtonAction: okButtonAction,
                okButtonTitle: okButtonTitle));
  }

  static List<Widget> _actions(BuildContext context) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(Localization.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : TextButton(
              child: Text(Localization.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
    ];
  }

  static List<Widget> _okCancelActions({
    required BuildContext context,
    required String okButtonTitle,
    required String cancelButtonTitle,
    required VoidCallback okButtonAction,
    required bool isCancelEnable,
    required VoidCallback cancelButtonAction,
  }) {
    return <Widget>[
      Platform.isIOS
              ? CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(cancelButtonTitle),
                  onPressed: () {
                          Navigator.of(context).pop();
                          cancelButtonAction();
                        },
                )
              : TextButton(
                  child: Text(cancelButtonTitle),
                  onPressed: () {
                          Navigator.of(context).pop();
                          cancelButtonAction();
                        },
                ),
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okButtonTitle),
              onPressed: () {
                Navigator.of(context).pop();
                okButtonAction();
              },
            )
          : TextButton(
              child: Text(okButtonTitle),
              onPressed: () {
                Navigator.of(context).pop();
                okButtonAction();
              },
            ),
    ];
  }

  static List<Widget> _okAction(
      {required BuildContext context,
      required String okButtonTitle,
      required VoidCallback okButtonAction}) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okButtonTitle),
              onPressed: () {
                Navigator.of(context).pop();
                okButtonAction();
              },
            )
          : TextButton(
              child: Text(okButtonTitle),
              onPressed: () {
                Navigator.of(context).pop();
                okButtonAction();
              },
            ),
    ];
  }

  static Future<bool> displayToast(String message) async {
    final result = await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: ColorUtils.primaryColor,
        textColor: Colors.white,
        fontSize: fontMedium);
    return result ?? false;
  }

  static SnackBar displaySnackBar({required String message}) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: fontMedium),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: ColorUtils.primaryColor,
    );
  }

  // Statement Request Dialog
  static void showStatementDialog(
      {required String image,
      required String headerText,
      required String subHeaderText,
      required VoidCallback onOkClick,
      required BuildContext context}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatementPopup(
          headerText: headerText,
          subHeaderText: subHeaderText,
          image: image,
          onOkClick: onOkClick,
        );
      },
    );
  }
}
