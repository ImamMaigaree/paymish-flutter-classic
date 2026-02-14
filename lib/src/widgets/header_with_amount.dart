import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';

class HeaderWithAmount extends StatelessWidget {
  final String titleText;
  final num amountValue;

  const HeaderWithAmount(
      {Key? key, this.titleText = '', this.amountValue = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText.trim() != ''
              ? Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: fontMedium,
                    fontFamily: fontFamilyPoppinsRegular,
                    color: ColorUtils.primaryTextColor,
                  ),
                  maxLines: 2,
                )
              : const SizedBox(),
          RichText(
            text: TextSpan(
              text: countryCurrency,
              style: const TextStyle(
                color: ColorUtils.primaryColor,
                fontSize: fontXMLarge,
                fontFamily: fontFamilySFMonoMedium,
                fontWeight: FontWeight.w900,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: amountValue != 0.0
                      ? " ${Utils.currencyFormat.format(amountValue)}"
                      : " ${0.0}",
                  style: const TextStyle(
                    color: ColorUtils.primaryColor,
                    fontSize: fontXMLarge,
                    fontFamily: fontFamilyPoppinsMedium,
                    fontWeight: FontWeight.w900,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('titleText', titleText));
    properties.add(DiagnosticsProperty<num>('amountValue', amountValue));
  }
}
