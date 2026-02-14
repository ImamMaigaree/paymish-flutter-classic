import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/localization/localization.dart';
import 'paymish_primary_button.dart';

class CommonPermissionPopup extends StatelessWidget {
  final String icon;
  final String permissionText;
  final VoidCallback onSkipTap;
  final VoidCallback onContinueTap;

  const CommonPermissionPopup(
      {Key? key,
      required this.icon,
      required this.permissionText,
      required this.onSkipTap,
      required this.onContinueTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 20.0,
      child: SizedBox(
        height: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _getContactImage(),
            _getPermissionText(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: <Widget>[
                  _getButton(
                      context: context,
                      isBackGround: false,
                      title: Localization.of(context).skip.toUpperCase(),
                      onClick: () {
                        Navigator.of(context).pop();
                        onSkipTap();
                                            }),
                  const SizedBox(width: 15.0),
                  _getButton(
                      context: context,
                      isBackGround: true,
                      title: Localization.of(context).allow.toUpperCase(),
                      onClick: () {
                        Navigator.of(context).pop();
                        onContinueTap();
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getContactImage() {
    return Image.asset(
      icon,
      height: 100,
      width: 100,
    );
  }

  Widget _getPermissionText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Text(
        permissionText,
        style: const TextStyle(
          fontSize: 14.0,
          color: ColorUtils.primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _getButton(
      {required BuildContext context,
      required bool isBackGround,
      required String title,
      required VoidCallback onClick}) {
    return Expanded(
      child: PaymishPrimaryButton(
        buttonText: title,
        isBackground: isBackGround,
        onButtonClick: onClick,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('icon', icon));
    properties.add(StringProperty('permissionText', permissionText));
    properties.add(DiagnosticsProperty<VoidCallback>('onSkipTap', onSkipTap));
    properties
        .add(DiagnosticsProperty<VoidCallback>('onContinueTap', onContinueTap));
  }
}
