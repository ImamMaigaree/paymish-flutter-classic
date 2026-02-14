import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';

@immutable
class PaymishSwitchView extends StatelessWidget {
  final bool value;
  final String title;
  final VoidCallback onButtonClick;

  const PaymishSwitchView({
    Key? key,
    required this.value,
    required this.title,
    required this.onButtonClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: fontMedium,
            fontWeight: FontWeight.w900,
            fontFamily: fontFamilyPoppinsRegular,
            color: ColorUtils.primaryTextColor,
            letterSpacing: 1,
          ),
        ),
        InkWell(
          onTap: onButtonClick,
          child: Switch(
                  value: value, // same as your old `checked`
                  onChanged: (newValue) {
                    onButtonClick(); // call the same function as before
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: ColorUtils.recentTextColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: ColorUtils.unCheckedSwitchColor,
                ),  
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('value', value));
    properties.add(StringProperty('title', title));
    properties
        .add(DiagnosticsProperty<Function>('onButtonClick', onButtonClick));
  }
}
