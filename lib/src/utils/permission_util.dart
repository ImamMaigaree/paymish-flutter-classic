import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dialog_utils.dart';
import 'localization/localization.dart';

class PermissionUtils {
  static void _noop() {}

  static void requestPermission(
      List<Permission> permissions, BuildContext context,
      {VoidCallback permissionGrant = _noop,
      VoidCallback permissionDenied = _noop,
      VoidCallback permissionNotAskAgain = _noop,
      bool isOpenSettings = false,
      bool isShowMessage = true}) async {
    final statuses = await permissions.request();
    final allPermissionGranted =
        statuses.values.every((status) => status.isGranted);

    if (allPermissionGranted) {
      permissionGrant.call();
    } else {
      permissionDenied.call();
      if (isOpenSettings) {
        DialogUtils.showOkCancelAlertDialog(
          context: context,
          message: Localization.of(context).alertPermissionNotRestricted,
          cancelButtonTitle: Localization.of(context).cancel,
          okButtonTitle: Localization.of(context).ok,
          okButtonAction: AppSettings.openAppSettings,
          cancelButtonAction: _noop,
          isCancelEnable: true,
        );
      } else if (isShowMessage) {
        DialogUtils.displayToast(
            Localization.of(context).alertPermissionNotRestricted);
      }
    }
  }

  static void checkPermissionStatus(
      Permission permission, BuildContext context,
      {VoidCallback permissionGrant = _noop,
      VoidCallback permissionDenied = _noop}) async {
    final status = await permission.status;
    if (status.isGranted) {
      permissionGrant.call();
    } else {
      permissionDenied.call();
    }
  }
}
