import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/localization/localization.dart';
import 'paymish_primary_button.dart';

class StatementPopup extends StatelessWidget {
  final String image;
  final String headerText;
  final String subHeaderText;
  final VoidCallback onOkClick;

  const StatementPopup(
      {Key? key,
      required this.image,
      required this.headerText,
      required this.subHeaderText,
      required this.onOkClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(circleTiny),
        ),
        elevation: spacingLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getContactImage(),
            _headerText(context),
            _subHeaderText(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: imageLarge, vertical: spacingXXLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _okButton(
                      context: context,
                      onClick: () {
                        Navigator.of(context).pop();
                        onOkClick();
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: spacingXXLarge),
      child: Image.asset(
        image,
        height: spacingXXXXLarge,
        width: spacingXXXXLarge,
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium, vertical: spacingSmall),
      child: Text(
        headerText,
        style: const TextStyle(
            fontSize: fontMedium,
            color: ColorUtils.primaryTextColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            fontFamily: fontFamilyRobotoLight),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _subHeaderText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium, vertical: spacingTiny),
      child: Text(
        subHeaderText,
        style: const TextStyle(
            fontSize: fontLarger,
            color: ColorUtils.primaryColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            fontFamily: fontFamilyRobotoLight),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _okButton(
      {required BuildContext context, required VoidCallback onClick}) {
    return Expanded(
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).ok.toUpperCase(),
        isBackground: true,
        onButtonClick: onClick,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('image', image));
    properties.add(StringProperty('headerText', headerText));
    properties.add(StringProperty('subHeaderText', subHeaderText));
    properties.add(DiagnosticsProperty<VoidCallback>('onOkClick', onOkClick));
  }
}
