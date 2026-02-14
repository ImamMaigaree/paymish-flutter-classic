import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/image_constants.dart';

@immutable
class PaymishMenuListItem extends StatelessWidget {
  final bool isSubTitle;
  final String titleText;
  final String subTitleText;
  final VoidCallback onClick;

  const PaymishMenuListItem({
    Key? key,
    required this.titleText,
    this.isSubTitle = false,
    required this.onClick,
    this.subTitleText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onClick,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: isSubTitle == true && subTitleText != ''
            ? menuListItemHeight
            : buttonHeight,
        margin: const EdgeInsets.symmetric(vertical: spacingSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(spacingTiny),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacingMedium),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Text
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: fontMedium,
                        fontWeight: FontWeight.w900,
                        fontFamily: fontFamilyPoppinsRegular,
                        color: ColorUtils.primaryTextColor,
                        letterSpacing: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // If Subtitle Text
                    isSubTitle == true &&
                            subTitleText != ''
                        ? Text(
                            subTitleText,
                            style: const TextStyle(
                              fontSize: fontXSmall,
                              fontWeight: FontWeight.w900,
                              fontFamily: fontFamilyPoppinsRegular,
                              color: ColorUtils.merchantHomeRow,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            // Next Icon Symbol
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: spacingMedium,
                  vertical: isSubTitle == true
                      ? spacingXLarge
                      : spacingLarge),
              child: Image.asset(ImageConstants.icNext),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isSubTitle', isSubTitle));
    properties.add(StringProperty('titleText', titleText));
    properties.add(StringProperty('subTitleText', subTitleText));
    properties.add(DiagnosticsProperty<VoidCallback>('onClick', onClick));
  }
}
