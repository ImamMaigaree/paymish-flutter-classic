import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/image_constants.dart';
import '../utils/localization/localization.dart';
import '../utils/navigation.dart';
import '../utils/preference_key.dart';
import '../utils/preference_utils.dart';

class PaymishAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackGround;
  final bool isHideBackButton;
  final bool isFromAuth;
  final bool isCloseIcon;

  const PaymishAppBar(
      {super.key,
      required this.title,
      required this.isBackGround,
      this.isCloseIcon = false,
      this.isHideBackButton = false,
      this.isFromAuth = true});

  @override
  Size get preferredSize => Size.fromHeight(isHideBackButton
      ? appbarSmallPreferredSize
      : appbarPreferredSize);

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Container(
      height: preferredSize.height,
      color: isBackGround ? ColorUtils.primaryColor : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: spacingTiny,
              ),
              child: isHideBackButton
                  ? Container(
                      height: screenSize.height * 0.01,
                    )
                  : FloatingActionButton(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      highlightElevation: 0,
                      hoverElevation: 0,
                      focusElevation: 0,
                      disabledElevation: 0,
                      tooltip: !isCloseIcon
                          ? Localization.of(context).labelBack
                          : Localization.of(context).labelClose,
                      child: Image.asset(
                        !isCloseIcon
                            ? ImageConstants.icBackArrow
                            : ImageConstants.icClose,
                        fit: BoxFit.contain,
                        height: spacingMedium,
                        color: isBackGround == true
                            ? Colors.white
                            : ColorUtils.primaryColor,
                      ),
                      onPressed: () {
                        // When user is logged in, just pop up
                        // When user is not logged in, redirect to login screen
                        // When user is logout, goes from auth or edit profile
                        if (getBool(PreferenceKey.isLogin)) {
                          NavigationUtils.pop(context);
                        } else if (isFromAuth) {
                          NavigationUtils.pop(context);
                        } else {
                          NavigationUtils.pushAndRemoveUntil(
                              context, routeLogin);
                        }
                      },
                    ),
            ),
            Padding(
                    padding: EdgeInsets.only(
                        left: spacingLarge, top: isHideBackButton ? 5.0 : 0.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: fontXMLarge,
                        fontFamily: fontFamilyPoppinsMedium,
                        color: isBackGround == true
                            ? Colors.white
                            : ColorUtils.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<bool>('isBackGround', isBackGround));
    properties
        .add(DiagnosticsProperty<bool>('isHideBackButton', isHideBackButton));
    properties.add(DiagnosticsProperty<bool>('isFromAuth', isFromAuth));
    properties.add(DiagnosticsProperty<bool>('isCloseIcon', isCloseIcon));
  }
}
