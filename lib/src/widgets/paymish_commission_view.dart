import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/image_constants.dart';

@immutable
class PaymishCommission extends StatelessWidget {
  final String userImage;
  final String commissionType;
  final String userName;
  final String commissionDetails;
  final num amount;
  final String date;
  final VoidCallback onClick;

  const PaymishCommission({
    Key? key,
    required this.userImage,
    required this.commissionType,
    required this.userName,
    required this.commissionDetails,
    required this.amount,
    required this.date,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onClick,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: spacingXXXXXXLarge,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          vertical: spacingSmall,
          horizontal: spacingLarge,
        ),
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
        child: ListTile(
          leading: Column(
            children: [
              CircleAvatar(
                radius: circleTiny,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(userImage),
              ),
            ],
          ),
          title: Text(
            commissionType,
            style: const TextStyle(
              fontSize: fontSmall,
              fontFamily: fontFamilyPoppinsMedium,
              color: ColorUtils.primaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: fontXSmall,
                  fontFamily: fontFamilyPoppinsRegular,
                  color: ColorUtils.merchantHomeRow,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    commissionDetails,
                    style: const TextStyle(
                      fontSize: fontXSmall,
                      fontFamily: fontFamilyPoppinsRegular,
                      color: ColorUtils.merchantHomeRow,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Image.asset(
                    ImageConstants.icCommissionEarned,
                    height: spacingSmall,
                    width: spacingSmall,
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: fontSmall,
                  fontFamily: fontFamilyPoppinsRegular,
                  color: ColorUtils.merchantHomeRow,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '$countryCurrency ',
                    style: TextStyle(
                      fontSize: fontLarge,
                      fontFamily: fontFamilySFMonoMedium,
                      fontWeight: FontWeight.w900,
                      color: ColorUtils.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    amount.toString(),
                    style: const TextStyle(
                      fontSize: fontLarge,
                      fontFamily: fontFamilyPoppinsMedium,
                      fontWeight: FontWeight.w900,
                      color: ColorUtils.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userImage', userImage));
    properties.add(StringProperty('commissionType', commissionType));
    properties.add(StringProperty('userName', userName));
    properties.add(StringProperty('commissionDetails', commissionDetails));
    properties.add(DoubleProperty('amount', amount.toDouble()));
    properties.add(StringProperty('date', date));
    properties.add(DiagnosticsProperty<VoidCallback>('onClick', onClick));
  }
}
