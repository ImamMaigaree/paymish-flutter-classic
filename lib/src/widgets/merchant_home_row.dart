import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';

class MerchantHomeRow extends StatelessWidget {
  final String description;
  final String title;
  final GestureTapCallback? onTap;

  const MerchantHomeRow(
      {Key? key,
      required this.description,
      required this.title,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
            right: spacingMedium,
            left: spacingMedium,
            top: spacingSmall,
            bottom: spacingSmall),
        padding: const EdgeInsets.only(top: spacingTiny, bottom: spacingTiny),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: ColorUtils.secondaryColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamilyPoppinsRegular,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: spacingLarge),
              child: Text(
                description,
                style: const TextStyle(
                  color: ColorUtils.merchantHomeRow,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamilyPoppinsRegular,
                ),
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
    properties.add(StringProperty('description', description));
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<GestureTapCallback?>('onTap', onTap));
  }
}
