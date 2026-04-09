import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';

@immutable
class PaymishPrimaryButton extends StatelessWidget {
  // to enable button with background or without background
  final bool isBackground;
  final String buttonText;
  final VoidCallback onButtonClick;

  const PaymishPrimaryButton({
    Key? key,
    required this.buttonText,
    required this.isBackground,
    required this.onButtonClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onButtonClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBackground ? ColorUtils.primaryColor : Colors.white,
          foregroundColor:
              isBackground ? Colors.white : ColorUtils.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacingTiny),
            side: BorderSide(
              color: !isBackground
                  ? ColorUtils.primaryColor
                  : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          buttonText.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontLarger,
            fontWeight: FontWeight.w900,
            fontFamily: fontFamilyCovesBold,
            color: isBackground ? Colors.white : ColorUtils.primaryColor,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isBackground', isBackground));
    properties.add(StringProperty('buttonText', buttonText));
    properties
        .add(DiagnosticsProperty<Function>('onButtonClick', onButtonClick));
  }
}
