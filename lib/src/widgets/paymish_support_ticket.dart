import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/image_constants.dart';

@immutable
class PaymishSupportTicket extends StatelessWidget {
  final String titleText;
  final String categoryText;
  final String statusText;
  final String detailsText;
  final String date;
  final GestureTapCallback? onClick;

  const PaymishSupportTicket({
    super.key,
    required this.titleText,
    required this.categoryText,
    required this.statusText,
    required this.detailsText,
    required this.date,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: spacingSmall,
          horizontal: spacingLarge,
        ),
        padding: const EdgeInsets.only(
            left: spacingLarge, top: spacingMedium, bottom: spacingMedium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(spacingTiny),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: circleTiny,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(right: spacingLarge, top: spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ticket Title Text
                            ticketTitleWidget(),
                            // Ticket Category Text
                            ticketCategoryWidget(),
                          ],
                        ),
                      ),
                      // Ticket Date Text
                      ticketDateWidget(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: spacingSmall, bottom: spacingMedium),
                    child: Text(
                      detailsText,
                      style: const TextStyle(
                        fontSize: fontSmall,
                        fontFamily: fontFamilyPoppinsRegular,
                        color: ColorUtils.primaryTextColor,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  ticketRowImageAndStatusWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketRowImageAndStatusWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(
          ImageConstants.icChatMessage,
          height: spacingLarge,
          width: spacingLarge,
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: spacingTiny,
            right: spacingSmall,
          ),
          decoration: const BoxDecoration(
            color: ColorUtils.cardStatusColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0),
              topRight: Radius.zero,
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.zero,
            ),
          ),
          child: Text(
            statusText,
            style: const TextStyle(
              fontSize: fontXSmall,
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.primaryTextColor,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  Widget ticketDescriptionWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          top: spacingSmall,
          right: spacingLarge,
          bottom: spacingSmall,
        ),
        child: Container(
          alignment: Alignment.topLeft,
          child: Text(
            detailsText,
            style: const TextStyle(
              fontSize: fontSmall,
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.primaryTextColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }

  Widget ticketDateWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: spacing2),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: fontXSmall,
          fontFamily: fontFamilyPoppinsRegular,
          color: ColorUtils.merchantHomeRow,
          letterSpacing: 1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget ticketCategoryWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: spacingTiny),
      child: Text(
        categoryText,
        style: const TextStyle(
          fontSize: fontXSmall,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamilyPoppinsRegular,
          color: ColorUtils.recentTextColor,
          letterSpacing: 1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget ticketTitleWidget() {
    return Text(
      titleText,
      style: const TextStyle(
        fontSize: fontMedium,
        fontFamily: fontFamilyPoppinsMedium,
        color: ColorUtils.primaryTextColor,
        letterSpacing: 1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('titleText', titleText));
    properties.add(StringProperty('categoryText', categoryText));
    properties.add(StringProperty('statusText', statusText));
    properties.add(StringProperty('detailsText', detailsText));
    properties.add(StringProperty('date', date));
    properties.add(DiagnosticsProperty<GestureTapCallback?>('onClick', onClick));
  }
}
